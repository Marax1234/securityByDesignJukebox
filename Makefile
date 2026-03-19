.PHONY: install install-dev lint css-build css-watch dev db stop \
        up down minikube-start build generate-certs create-namespace enable-ingress \
        load-image apply-secrets apply-manifests wait-healthy k8s-status k8s-logs

# Einmalig: Virtualenv + Abhängigkeiten installieren
install:
	python3 -m venv .venv
	.venv/bin/pip install --upgrade pip
	.venv/bin/pip install -r backend/requirements.txt
	npm install
	@[ -f .env ] || cp .env.example .env
	@echo ""
	@echo "Fertig. CSS bauen mit: make css-build  |  Starten mit: make dev"

# CSS kompilieren (einmalig, minifiziert)
css-build:
	npm run css:build

# CSS im Watch-Modus (während der Entwicklung)
css-watch:
	npm run css:watch

# Dev-Abhängigkeiten installieren (Linting, Type-Checking)
install-dev:
	python3 -m venv .venv
	.venv/bin/pip install --upgrade pip
	.venv/bin/pip install -r requirements-dev.txt

# Linting + Type-Checking
lint:
	.venv/bin/ruff check backend/
	.venv/bin/mypy backend/app.py

# Datenbank + Backend + CSS-Watcher starten (alles in einem)
dev: css-build
	docker-compose up -d db
	@echo "Warte auf Postgres..."
	@until docker exec jukebox_db pg_isready -U jukebox > /dev/null 2>&1; do sleep 1; done
	@echo "Postgres bereit."
	@npm run css:watch & CSS_PID=$$!; \
	trap "kill $$CSS_PID 2>/dev/null" EXIT INT TERM; \
	.venv/bin/python backend/app.py

# Nur Datenbank stoppen
stop:
	docker-compose down

# ===========================================================================
# Kubernetes / Minikube targets
# ===========================================================================

# Build the Docker image locally (CSS must be compiled first)
build: css-build
	docker build -t jukebox:local .

# Full automated deployment — runs all steps in order
up: minikube-start build generate-certs create-namespace enable-ingress load-image apply-secrets apply-manifests wait-healthy
	@echo ""
	@echo "=== Ready ==="
	@echo "NodePort URL : http://$(shell minikube ip):30007"
	@echo "Ingress URL  : https://jukebox.local  (add '$(shell minikube ip) jukebox.local' to /etc/hosts)"

# Start Minikube if it is not already running
minikube-start:
	@if ! minikube status --format='{{.Host}}' 2>/dev/null | grep -q Running; then \
		echo "Starting Minikube..."; \
		minikube start --driver=docker; \
	else \
		echo "Minikube already running."; \
	fi

# Generate self-signed CA + leaf cert for jukebox.local (idempotent)
generate-certs:
	@mkdir -p infrastructure/certs
	@if [ ! -f infrastructure/certs/rootCA.pem ]; then \
		echo "Generating CA..."; \
		openssl genrsa -out infrastructure/certs/rootCA.key 4096; \
		openssl req -x509 -new -nodes \
			-key infrastructure/certs/rootCA.key \
			-sha256 -days 825 \
			-subj "/CN=Jukebox Local CA" \
			-out infrastructure/certs/rootCA.pem; \
	else \
		echo "CA already exists, skipping."; \
	fi
	@if [ ! -f infrastructure/certs/tls.crt ]; then \
		echo "Generating leaf certificate..."; \
		openssl genrsa -out infrastructure/certs/tls.key 2048; \
		printf '[req]\ndistinguished_name=req\n[SAN]\nsubjectAltName=DNS:jukebox.local\n' \
			> infrastructure/certs/san.cnf; \
		openssl req -new \
			-key infrastructure/certs/tls.key \
			-subj "/CN=jukebox.local" \
			-reqexts SAN \
			-config infrastructure/certs/san.cnf \
			-out infrastructure/certs/tls.csr; \
		openssl x509 -req -in infrastructure/certs/tls.csr \
			-CA infrastructure/certs/rootCA.pem \
			-CAkey infrastructure/certs/rootCA.key \
			-CAcreateserial \
			-days 825 -sha256 \
			-extfile infrastructure/certs/san.cnf \
			-extensions SAN \
			-out infrastructure/certs/tls.crt; \
	else \
		echo "Leaf cert already exists, skipping."; \
	fi

# Apply namespace manifest if the namespace does not exist yet
create-namespace:
	@if ! kubectl get namespace jukebox > /dev/null 2>&1; then \
		echo "Creating namespace jukebox..."; \
		kubectl apply -f infrastructure/k8s/namespace.yaml; \
	else \
		echo "Namespace jukebox already exists."; \
	fi

# Enable the ingress-nginx addon and wait for its controller pod to become ready
enable-ingress:
	@minikube addons enable ingress
	@echo "Waiting for ingress-nginx controller..."
	@kubectl rollout status deployment/ingress-nginx-controller \
		-n ingress-nginx --timeout=120s

# Load the locally built image into Minikube
load-image:
	@echo "Loading jukebox:local into Minikube..."
	minikube image load jukebox:local

# Apply secrets: postgres-secret from manifest, app-secret generated at runtime, TLS secret from certs
apply-secrets:
	kubectl apply -f infrastructure/k8s/postgres-secret.yaml
	@kubectl create secret generic app-secret \
		--namespace jukebox \
		--from-literal=SECRET_KEY="$$(openssl rand -base64 32)" \
		--dry-run=client -o yaml | kubectl apply -f -
	@kubectl create secret tls jukebox-tls \
		--namespace jukebox \
		--cert=infrastructure/certs/tls.crt \
		--key=infrastructure/certs/tls.key \
		--dry-run=client -o yaml | kubectl apply -f -

# Apply all remaining manifests in dependency order
apply-manifests:
	kubectl apply -f infrastructure/k8s/serviceaccount.yaml
	kubectl apply -f infrastructure/k8s/postgres-pvc.yaml
	kubectl apply -f infrastructure/k8s/postgres-deployment.yaml
	kubectl apply -f infrastructure/k8s/postgres-service.yaml
	kubectl apply -f infrastructure/k8s/networkpolicy.yaml
	kubectl apply -f infrastructure/k8s/deployment.yaml
	kubectl apply -f infrastructure/k8s/service.yaml
	kubectl apply -f infrastructure/k8s/ingress.yaml

# Wait for both deployments to roll out, then probe the app
wait-healthy:
	@echo "Waiting for postgres rollout..."
	@kubectl rollout status deployment/postgres -n jukebox --timeout=120s
	@echo "Waiting for jukebox rollout..."
	@kubectl rollout status deployment/jukebox -n jukebox --timeout=120s
	@echo "Probing app from inside the cluster..."
	@kubectl run probe --image=curlimages/curl:8.7.1 --restart=Never --rm -i \
		--namespace jukebox \
		-- curl -sf http://jukebox-service/ > /dev/null && echo "App responded OK."

# Tear down the entire Minikube cluster
down:
	minikube delete

# Show all resources in the jukebox namespace
k8s-status:
	kubectl get all,ingress,secret,networkpolicy -n jukebox

# Tail logs for the jukebox app pod
k8s-logs:
	kubectl logs -n jukebox -l app=jukebox --tail=100 -f
