# Security Audit Report – Jukebox (STG-TINF23F)

> **Erstellt:** 2026-03-19
> **Analysiert:** Gesamtes Repository `/home/marax/repos/dhbw/jain/jukebox`
> **Methode:** Automatisierte Codeanalyse mit parallelen Sub-Agents pro Scope

---

## Gesamtübersicht

| Scope | Bereich | Max. Punkte | Geschätzte Punkte | Status |
|-------|---------|:-----------:|:-----------------:|--------|
| 1 | Anforderungen & Architektur | 15 | ~8 | ⚠️ PARTIAL |
| 2 | Threat Modeling | 15 | ~1 | ❌ KRITISCH |
| 3 | Secure Coding & App-Security | 15 (+10) | ~12 | ✅ GUT |
| 4 | CI/CD-Pipeline | 25 | ~17 | ⚠️ PARTIAL |
| 5 | Kubernetes Security | 15 | ~15 | ✅ VOLLSTÄNDIG |
| 6 | Abgabe & Reproduzierbarkeit | 15 | ~8 | ⚠️ PARTIAL |
| 7 | Dokumentation | 8 | ~2 | ❌ KRITISCH |
| **Σ** | **Gesamt** | **100 (+10)** | **~63** | ⚠️ |

> **Hinweis:** Scope 8 (Präsentation) wurde nicht bewertet, da sie nicht automatisch prüfbar ist.

---

## 🏗️ SCOPE 1 – Anforderungen & Architektur

### 1.1 Projektdefinition

| Punkt | Status | Befund |
|-------|--------|--------|
| Projektidee festgelegt | ✅ | README.md L3-5: klare Beschreibung als Musik-Review-Plattform (wie Letterboxd) |
| Frontend-Sprachen definiert | ✅ | HTML, Vanilla JS, Tailwind CSS, Jinja2-Templates in `frontend/` |
| Backend-Sprachen definiert | ✅ | Python 3.11 / Flask, PostgreSQL – belegt durch Dockerfile L1, backend/app.py |
| Rollen im System definiert | ❌ | **Kein Rollenkonzept dokumentiert.** Nur eine implizite Nutzerrolle (alle Nutzer gleichgestellt). Kein Admin, kein Moderator. |

### 1.2 Security Requirements

| Punkt | Status | Befund |
|-------|--------|--------|
| Mind. 5 Requirements definiert | ✅ | README.md: SR-01 bis SR-05 vorhanden |
| Jedes Req. prüfbar formuliert | ✅ | Konkrete Werte: SR-01 "1800 Sekunden", SR-04 Regex-Pattern, SR-05 Header-Tabelle |
| Eindeutige IDs (SR-01…SR-05) | ✅ | Konsistent im gesamten README verwendet |
| Bezug auf Komponente/Datenfluss | ✅ | SR-01→Session, SR-02→Cookie, SR-03→CORS, SR-04→Auth, SR-05→HTTP-Response |
| Code-Verweis für jedes Req. | ✅ | README enthält Verweise: z. B. `backend/app.py L156-168` für SR-01 |
| Test/Nachweis für jedes Req. | ⚠️ | **Kein einziger Testfall dokumentiert.** Nur Beschreibung der Mechanismen – kein `curl`-Befehl, kein manueller Testfall. |
| Alle Req. vollständig oder begründet abweichend | ⚠️ | Abweichungen nicht formal dokumentiert |

**Implementierung verifiziert:**
- `backend/app.py:154` → `INACTIVITY_TIMEOUT = 1800` (SR-01)
- `backend/app.py:82-89` → SESSION_COOKIE_* Flags (SR-02)
- `backend/app.py:31-39` → CORS-Konfiguration (SR-03)
- `backend/app.py:196-207` → `validate_password()` mit Regex (SR-04)
- `backend/app.py:174-190` → `set_security_headers()` (SR-05)

### 1.3 Architekturdiagramm

| Punkt | Status | Befund |
|-------|--------|--------|
| Architekturdiagramm erstellt | ❌ | **Kein Diagramm vorhanden.** Kein `.png`, `.svg`, `.drawio`, kein Mermaid-Diagramm, keine ASCII-Art. |
| Alle Komponenten eingezeichnet | ❌ | Mangels Diagramm nicht erfüllt (Komponenten existieren im Code) |
| Nutzer als externer Akteur | ❌ | Mangels Diagramm nicht erfüllt |
| CI/CD-Pipeline im Diagramm | ❌ | Mangels Diagramm nicht erfüllt |
| K8s-Cluster (NS/Pods/Svc/Ingress) | ❌ | Mangels Diagramm nicht erfüllt |
| Verbindungstest: Diagramm ↔ Realität | ❌ | Nicht prüfbar ohne Diagramm |

> **Alle Komponenten existieren als Dateien** (deployment.yaml, ingress.yaml, namespace.yaml etc.) – es fehlt lediglich die visuelle Dokumentation.

**Deploy-Job in Pipeline fehlt zudem** – cicd.yml L213-223: Registry-Push ist auskommentiert, kein Deploy-Job.

### Bewertung SCOPE 1

**Geschätzte Punkte: ~8/15** – Security Requirements gut umgesetzt und referenziert. Architekturdiagramm vollständig fehlend (–5 Punkte), Testfälle für Requirements fehlen (–2 Punkte).

---

## 🔍 SCOPE 2 – Threat Modeling

> **⚠️ KRITISCH: Gesamter Scope fehlt in der Dokumentation.**

### 2.1 Systemmodell & DFD

| Punkt | Status | Befund |
|-------|--------|--------|
| DFD erstellt | ❌ | **Kein DFD in `docs/`, README oder anderswo.** |
| Datenflüsse mit Protokoll beschriftet | ❌ | Kein DFD vorhanden |
| Vertrauensgrenzen klar eingezeichnet | ❌ | Kein DFD vorhanden |
| Externe Entitäten markiert | ❌ | Kein DFD vorhanden |
| DFD ↔ Architekturdiagramm konsistent | ❌ | Keines der beiden vorhanden |

### 2.2 STRIDE-Bedrohungsanalyse

| STRIDE-Kategorie | Impl.-Status | Code-Nachweis | Dokumentiert |
|-----------------|:------------:|----------------|:------------:|
| **S**poofing | ⚠️ PARTIAL | `app.py:156-169` Session-Timeout, `app.py:268` bcrypt-Verify | ❌ |
| **T**ampering | ✅ | `app.py:60` html.escape(), `app.py:263` parameterisierte Queries | ❌ |
| **R**epudiation | ⚠️ PARTIAL | `app.py:272,400,438,466` logger.info() für Aktionen | ❌ |
| **I**nformation Disclosure | ✅ | `app.py:176-189` Security-Header, `app.py:488` generische Fehlermeldung | ❌ |
| **D**enial of Service | ✅ | `app.py:47-51` Flask-Limiter 200/Tag, 5/min Login | ❌ |
| **E**levation of Privilege | ⚠️ PARTIAL | `app.py:428` Ownership-Check (nur eigene Reviews) | ❌ |

| Punkt | Status | Befund |
|-------|--------|--------|
| STRIDE-Analyse pro Komponente | ❌ | **Keine Dokumentation.** Countermeasures im Code vorhanden, aber nicht als STRIDE-Analyse aufbereitet. |
| STRIDE pro Trust-Boundary-Fluss | ❌ | Keine Dokumentation |
| Mindestens eine Tabelle im Vorlesungsformat | ❌ | Keine Tabelle vorhanden |
| Mind. 3 von 6 STRIDE-Kategorien implementiert | ⚠️ | T, I, D vollständig implementiert; S, R, E partiell – aber nirgends dokumentiert |
| Nicht-implementierte Kategorien begründet | ❌ | Keine Begründung |
| Gegenmaßnahmen im Code auffindbar | ⚠️ | Im Code vorhanden, keine Dokumentation |

### 2.3 Attack Tree

| Punkt | Status | Befund |
|-------|--------|--------|
| Worst-Case-Szenario definiert | ❌ | **Kein Attack Tree.** |
| Attack Tree mit 3 Ebenen | ❌ | Nicht vorhanden |
| Jedes Blatt mit Gegenmaßnahme | ❌ | Nicht vorhanden |
| Attack Tree ↔ STRIDE konsistent | ❌ | Nicht prüfbar |
| Zwei Angriffspfade konkret blockiert | ❌ | Nicht dokumentiert |

### Bewertung SCOPE 2

**Geschätzte Punkte: ~1/15** – Die Sicherheitsmaßnahmen im Code sind stark und decken mindestens 3 STRIDE-Kategorien ab. Jedoch existiert **keine einzige Zeile Threat-Modeling-Dokumentation** (kein DFD, keine STRIDE-Tabelle, kein Attack Tree). Dies ist der größte Schwachpunkt des Projekts.

---

## 💻 SCOPE 3 – Secure Coding & App-Security

### 3.1 Fehlerbehandlung

| Punkt | Status | Befund |
|-------|--------|--------|
| Alle Endpoints mit Fehlerbehandlung | ✅ | `app.py:482-488`: globaler `@app.errorhandler(Exception)` + Endpoint-spezifische Returns |
| Generische Fehlermeldungen nach außen | ✅ | "Ungültige Anmeldedaten", "Internal server error" – kein Stack Trace, kein DB-Fehler |
| Interne Fehler geloggt, nicht an Client | ✅ | `app.py:487`: `logger.exception()` intern; Response enthält nur generische Meldung |

**Verbindungstest-Prüfung:**
- 404-Route: `@app.errorhandler(Exception)` greift
- 400 bei ungültigem JSON: Input-Validierung gibt 400 zurück
- DB-Fehler: `psycopg2.errors.UniqueViolation` (L313) wird zu 409 mit "Benutzername bereits vergeben"

### 3.2 Eingabevalidierung

| Punkt | Status | Befund |
|-------|--------|--------|
| Backend: Alle Parameter validiert | ✅ | `app.py:57-72`: `sanitize_string()` (HTML-Escape, max 255 Zeichen), `sanitize_int()` mit Range-Check |
| Frontend: Pflichtfelder geprüft | ✅ | `login.js:7-10`, `signup.js:40-43`, `app.js:206-208` – Client-seitige Checks |
| Validierung im Backend (autoritär) | ✅ | Alle Validierungen doppelt: Frontend für UX, Backend für Sicherheit |
| Bibliothek/Logik dokumentiert | ✅ | `html.escape()` (stdlib) + Custom-Funktionen in Code klar benannt |

**Code-Nachweise:**
- SQL-Injection-Schutz: `app.py:263` `execute("SELECT * FROM users WHERE username = %s", (username,))` – 100% parametrisiert
- Stars-Range: `app.py:385-388` (1-5 Integer-Validierung)
- Username-Länge: `app.py:289-292` (3-50 Zeichen)

### 3.3 Authentifizierung & Autorisierung

| Punkt | Status | Befund |
|-------|--------|--------|
| Login mit sicherer Passwort-Verarbeitung | ✅ | `app.py:92`: Flask-Bcrypt; `app.py:298`: `bcrypt.generate_password_hash()`; KEIN MD5/SHA1 |
| Session-Management (HttpOnly + Secure) | ✅ | `app.py:84-86`: `SESSION_COOKIE_SECURE=_is_production`, `SESSION_COOKIE_HTTPONLY=True`, `SESSION_COOKIE_SAMESITE="Lax"` |
| Alle geschützten Routen gesichert | ✅ | `app.py:213-219`: `@login_required`-Decorator auf `/api/reviews` (L337) und `/api/reviews/<id>` (L415) |
| RBAC (bei mehreren Rollen) | ❌ | **Kein RBAC** – Single-Role-System (alle Nutzer gleichwertig). Nur Ownership-Check: `app.py:428` |
| SSO (Optional/Bonus) | ❌ | Nicht implementiert |
| MFA (Optional/Bonus) | ❌ | Nicht implementiert |

**Verbindungstest:**
- Ohne Token → 401: `login_required` gibt `{"error": "Unauthorized"}, 401` zurück ✅
- Inaktivitäts-Timeout: `app.py:154-168` `INACTIVITY_TIMEOUT = 1800` ✅
- Ownership-Verletzung → 403: `app.py:428-431` ✅

### 3.4 Secret-Hygiene

| Punkt | Status | Befund |
|-------|--------|--------|
| Keine Secrets im Repository | ⚠️ | **Historische Verletzung:** `infrastructure/certs/rootCA.pem` und `tls.crt` waren im Initial-Commit `bac8c9f` enthalten (public certs, kein privater Key). Werden aktuell gelöscht (git status: `D infrastructure/certs/rootCA.pem`). Private Keys (`.key`) waren nie im Repo. |
| Secrets via Env-Variablen / K8s Secrets | ✅ | `app.py:78`: `os.environ.get("SECRET_KEY")`; `deployment.yaml:52-55`: `secretRef` für postgres-secret + app-secret |
| .gitignore deckt alle Secret-Dateien | ✅ | `.gitignore`: `*.key`, `*.pem`, `*.crt`, `*.csr`, `*.srl`, `.env.*` (außer `.env.example`), `infrastructure/k8s/postgres-secret.yaml` |

> **Hinweis:** `docker-compose.yml:9-10` enthält Default-Dev-Credentials (akzeptabel für lokale Entwicklung, nicht für Produktion).

### 3.5 TLS-Readiness

| Punkt | Status | Befund |
|-------|--------|--------|
| Eigene CA aufgesetzt | ✅ | `infrastructure/certs/rootCA.pem` + `rootCA.key` vorhanden; `Makefile:90-125` generiert CA automatisch |
| TLS-Zertifikat von CA signiert | ✅ | `infrastructure/certs/tls.crt` von `rootCA.pem` signiert; gültig bis 2028 |
| Zertifikat im K8s Ingress eingebunden | ✅ | `infrastructure/k8s/ingress.yaml:12-14`: `secretName: jukebox-tls`; `apply-secrets` im Makefile erstellt Secret |
| HTTP → HTTPS Redirect | ✅ | `ingress.yaml:7-8`: `ssl-redirect: "true"`, `force-ssl-redirect: "true"` |
| HSTS-Header | ✅ | `app.py:180`: `Strict-Transport-Security: max-age=31536000; includeSubDomains` |

### Bewertung SCOPE 3

**Geschätzte Punkte: ~12/15** – Sehr starke Implementierung. Abzüge nur für: Certificate-History-Problem (–1), kein RBAC/kein dokumentiertes Rollensystem (–1), fehlende Bonuspunkte (SSO/MFA: 0/10 Bonus).

---

## 🔄 SCOPE 4 – CI/CD-Pipeline

### 4.1 Pipeline-Trigger

| Punkt | Status | Befund |
|-------|--------|--------|
| Trigger auf main-Branch | ✅ | `cicd.yml:4-7`: `on: push/pull_request: branches: [main]` |
| Kein manueller Schritt nötig | ✅ | Vollautomatisch |

### 4.2 Schritt-Reihenfolge & Abhängigkeiten

Pipeline-Jobs und ihre Abhängigkeiten:

```
sbom → scan → build → sign → quality-gate → [DEPLOY FEHLT]
```

| Job | Abhängigkeit (needs:) | Erforderliche Reihenfolge | Status |
|-----|----------------------|--------------------------|--------|
| sbom | – | [1] SBOM | ✅ |
| scan | sbom (L32) | [2] SAST+SCA+Secret | ✅ |
| build | scan (L78) | [3] Build | ✅ |
| sign | build (L106) | [4] Image Signing | ✅ |
| quality-gate | sign (L146) | [5] Quality Gate | ✅ |
| deploy | **FEHLT** | [6] Deploy → K8s | ❌ |

| Punkt | Status | Befund |
|-------|--------|--------|
| Schritte 1-4 laufen vor Quality Gate | ✅ | Abhängigkeitskette korrekt |
| Deploy nur nach erfolgreichem QG | ❌ | **Kein Deploy-Job** – Registry-Push in `cicd.yml:209-223` auskommentiert |
| Abhängigkeiten explizit definiert | ✅ | `needs:` überall gesetzt |

### 4.3 SBOM-Erzeugung

| Punkt | Status | Befund |
|-------|--------|--------|
| SBOM automatisch generiert (Syft) | ✅ | `cicd.yml:16-22`: `syft dir:. -o cyclonedx-json=evidence/sbom/sbom.json` |
| SBOM referenziert gebautes Image | ❌ | **SBOM analysiert Source-Verzeichnis (`.`), nicht das Container-Image.** Wird im `sbom`-Job vor dem Build generiert. Richtig wäre: `syft docker:jukebox:latest` nach dem Build. |
| SBOM-Format dokumentiert | ✅ | CycloneDX JSON (im Job-Namen und `-o cyclonedx-json=` Flag) |
| SBOM als Artefakt gespeichert | ✅ | `cicd.yml:23-26`: Upload nach `evidence/sbom/sbom.json` |

### 4.4 SAST / SCA / Secret Scan

| Tool | Art | Status | Konfiguration |
|------|-----|--------|---------------|
| Bandit | SAST | ✅ | `cicd.yml:44-48`: `bandit -r backend/ --severity-level high -f json` → `evidence/sast/bandit.json` |
| pip-audit | SCA | ✅ | `cicd.yml:49-53`: `pip-audit -r backend/requirements.txt -f json` → `evidence/sca/pip-audit.json` |
| Gitleaks v8.18.2 | Secret Scan | ✅ | `cicd.yml:54-64`: `--exit-code 1` → Pipeline bricht ab bei Findings → `evidence/secrets/gitleaks.json` |

| Punkt | Status | Befund |
|-------|--------|--------|
| Alle drei Tools integriert | ✅ | Bandit, pip-audit, Gitleaks vorhanden |
| Berichte in /evidence/ gespeichert | ✅ | `cicd.yml:65-72`: `if: always()` Upload |
| Gleicher Code-Stand | ✅ | Alle drei im selben `scan`-Job, einmalige Checkout |

### 4.5 Build & Container-Build

| Punkt | Status | Befund |
|-------|--------|--------|
| App in Pipeline gebaut | ✅ | `cicd.yml:86-99`: npm run css:build + docker build |
| Container-Image in Pipeline gebaut | ✅ | `docker build -t jukebox:latest .` |
| Kein `USER root` als finale Anweisung | ✅ | `Dockerfile:35`: `USER ${APP_USER}` (UID 1000) als letzter User-Befehl |
| `COPY . .` mit .dockerignore | ✅ | `.dockerignore`: excludes `.env`, `*.key`, `*.pem`, `.git`, venv etc. |
| Base-Image mit Version gepinnt | ⚠️ | `Dockerfile:2`: `FROM python:3.11-slim` – Version gepinnt, aber **kein Digest** (`@sha256:...`). Anfällig für Image-Drift. |
| Minimales Base-Image | ✅ | `python:3.11-slim` ist schlank; kein Ubuntu/Debian Full |

### 4.6 Image Signing

| Punkt | Status | Befund |
|-------|--------|--------|
| Image nach Build signiert (Cosign) | ✅ | `cicd.yml:101-137`: `cosign sign-blob --key cosign.key --output-signature evidence/signing/image.sig` |
| Signing-Keypair + Public Key gespeichert | ✅ | `secrets.COSIGN_PRIVATE_KEY`, `secrets.COSIGN_PUBLIC_KEY` in GitHub Secrets; `secrets.COSIGN_PASSWORD` |
| `image.sig` in /evidence/ | ✅ | `cicd.yml:132-137`: Upload nach `evidence/signing/image.sig` + `sign.log` |
| Transparency Log (Rekor) | ⚠️ | `cicd.yml:118`: `COSIGN_TLOG_UPLOAD: "false"` – bewusst deaktiviert (kein öffentliches Transparency Log). Für lokale Deployments akzeptabel. |

### 4.7 Quality Gate

| Abbruchbedingung | Status | Mechanismus |
|-----------------|--------|-------------|
| Secrets gefunden | ✅ | Gitleaks `--exit-code 1` in `scan`-Job blockiert alle Downstream-Jobs |
| CVSS ≥ 7.0 (HIGH/CRITICAL) | ✅ | `cicd.yml:177-184`: Trivy `exit-code: "1"`, `severity: HIGH,CRITICAL` + `trivy.yaml:exit-code: 1` |
| Fehlende/ungültige Signatur | ✅ | `cicd.yml:161-174`: `cosign verify-blob` – Non-Zero-Exit bei Fehler |
| Kein `continue-on-error: true` | ✅ | Grep über cicd.yml: kein `continue-on-error` gefunden |

### 4.8 Deployment nach Kubernetes

| Punkt | Status | Befund |
|-------|--------|--------|
| Deploy nach erfolgreichem QG | ❌ | **Kein Deploy-Job in der Pipeline.** `cicd.yml:209-223`: Push zur Registry auskommentiert. |
| Deployment-Weg dokumentiert | ⚠️ | K8s-Manifeste vorhanden, aber kein automatisierter CI/CD-Deploy. `deploy.sh` in CLAUDE.md erwähnt, existiert aber nicht. |
| Pull-Secret in K8s konfiguriert | ❌ | Kein `imagePullSecrets` in deployment.yaml (Minikube-lokal via `imagePullPolicy: Never`) |

### Bewertung SCOPE 4

**Geschätzte Punkte: ~17/25** – Quality Gate, SAST/SCA/Secret Scan und Image Signing stark implementiert. Hauptabzüge: kein Deploy-Job (–5), SBOM von Source statt Image (–2), Base-Image kein Digest (–1).

---

## ☸️ SCOPE 5 – Kubernetes Security

> **✅ VOLLSTÄNDIG ERFÜLLT** – Bestes Scope im gesamten Projekt.

### 5.1 Namespace & Service Account

| Punkt | Status | Befund |
|-------|--------|--------|
| Eigener Namespace (nicht `default`) | ✅ | `namespace.yaml:4`: `name: jukebox` |
| Eigener Service Account | ✅ | `serviceaccount.yaml:4-6`: `name: jukebox-sa`, `automountServiceAccountToken: false` |
| Keine ClusterRoleBindings | ✅ | Keine RBAC-Dateien im Repo – minimale Standardrechte |
| SA im Deployment referenziert | ✅ | `deployment.yaml:16`: `serviceAccountName: jukebox-sa` |

**Bonus:** `automountServiceAccountToken: false` verhindert automatisches Token-Mounting – Security-Best-Practice.

### 5.2 Security Context

Alle Felder sind auf **Container-Ebene** gesetzt (Jukebox-App, Init-Container und PostgreSQL):

| Einstellung | Jukebox App | Init Container | PostgreSQL |
|-------------|:-----------:|:--------------:|:----------:|
| `runAsNonRoot: true` | ✅ (L44) | ✅ (L30) | ✅ (L17,24) |
| `runAsUser: <non-root>` | ✅ (UID 1000, L45) | ✅ (UID 1000, L31) | ✅ (UID 999, L18,25) |
| `readOnlyRootFilesystem: true` | ✅ (L46) | ✅ (L32) | ✅ (L26) |
| `allowPrivilegeEscalation: false` | ✅ (L47) | ✅ (L33) | ✅ (L27) |
| `capabilities.drop: [ALL]` | ✅ (L48-50) | ✅ (L34-36) | ✅ (L28-30) |

**Schreibzugriff via emptyDir:**

| Anwendung | Mount-Pfad | Volume-Typ | Zweck |
|-----------|-----------|-----------|-------|
| Jukebox | `/app/flask_session` | `emptyDir` | Session-Dateien |
| Jukebox | `/tmp` | `emptyDir` | Temp-Dateien |
| PostgreSQL | `/var/run/postgresql` | `emptyDir` | Socket-Dateien |
| PostgreSQL | `/tmp` | `emptyDir` | Temp-Dateien |
| PostgreSQL | `/var/lib/postgresql/data` | PVC | Persistente DB-Daten |

### 5.3 Network Policy

Drei Policies in `networkpolicy.yaml`:

| Policy | Typ | Selektiert | Regelt |
|--------|-----|-----------|--------|
| `default-deny-all` | Ingress+Egress | `{}` (alle Pods) | Blockiert alles (Zero-Trust) |
| `allow-ingress-nginx-to-app` | Ingress+Egress | `app: jukebox` | Eingehend: nur von ingress-nginx (port 5000); Ausgehend: → postgres (5432) + kube-dns (53) |
| `allow-app-to-postgres` | Ingress+Egress | `app: postgres` | Eingehend: nur von jukebox-SA; Ausgehend: → kube-dns (53) |

| Punkt | Status | Befund |
|-------|--------|--------|
| Network Policy im richtigen Namespace | ✅ | Alle in `namespace: jukebox` |
| Ingress auf notwendige Ports beschränkt | ✅ | Nur port 5000 von ingress-nginx-Namespace |
| Egress definiert und begründet | ✅ | postgres:5432 + kube-dns:53 – minimal necessary |
| Richtigem Pod zugeordnet (Labels) | ✅ | `app: jukebox` und `app: postgres` matchen deployment.yaml Labels |

**TLS-Enforcement:** `ingress.yaml:7-8`: `ssl-redirect: "true"`, `force-ssl-redirect: "true"` ✅

### Bewertung SCOPE 5

**Geschätzte Punkte: ~15/15** – Musterhaft. Zero-Trust-Netzwerk, vollständige Security-Contexts, korrekter Service Account. Keine Beanstandungen.

---

## 📦 SCOPE 6 – Abgabe & Reproduzierbarkeit

### 6.1 Repository-Struktur

| Verzeichnis / Datei | Status | Befund |
|--------------------|--------|--------|
| `/frontend/` | ✅ | Templates + Static Assets vorhanden |
| `/backend/` | ✅ | app.py, requirements.txt, database.py vorhanden |
| `/infrastructure/k8s/` | ✅ | 9 Manifeste vorhanden |
| Pipeline-Konfig (`.github/workflows/`) | ✅ | cicd.yml vorhanden |
| `/evidence/` mit Unterordnern | ❌ | **Kein evidence/-Verzeichnis im Repo.** Pipeline erzeugt Artefakte nur als GitHub-Artifacts, nicht als committed Verzeichnis. |
| `VERSION.txt` | ❌ | **Fehlt vollständig.** |
| `README.md` mit Setup-Guide | ⚠️ | README.md vorhanden, aber enthält nur Security Requirements. Kein Architektur-Schaubild, keine Deployment-Anleitung. Vollständiger Setup-Guide ist in `docs/local-dev.md`. |
| `Makefile` | ✅ | 211 Zeilen, vollständig implementiert |

### 6.2 Makefile

Das `make up`-Target ist **vollständig und produktionsbereit**:

```
make up = minikube-start + build + generate-certs + create-namespace + enable-ingress
        + load-image + apply-secrets + apply-manifests + wait-healthy + port-forward
```

| Anforderung | Target | Status | Details |
|-------------|--------|--------|---------|
| Cluster starten | `minikube-start` | ✅ | Minikube mit docker-Driver, wartet auf API-Server |
| Namespace anlegen | `create-namespace` | ✅ | Idempotent: prüft Existenz vor Anlage |
| Ingress ausrollen | `enable-ingress` | ✅ | ingress-nginx Addon + rollout wait |
| Image aus .tar laden | `load-image` | ✅ | `kind load` / Minikube-Load |
| K8s-Manifeste anwenden | `apply-manifests` | ✅ | In Dependency-Reihenfolge |
| Auf Running/Ready warten | `wait-healthy` | ✅ | `kubectl wait --for=condition=ready` + HTTP-Probe |
| "Ready" ausgeben | – | ✅ | `@echo "=== Ready ==="` + URL |

**Bonus:** Zertifikat-Generierung (`generate-certs`) ist idempotent und vollautomatisch.

### 6.3 ZIP-Abgabe

| Ordner | Status | Befund |
|--------|--------|--------|
| `Image/` (tar, digest.txt, .sig, Berichte) | ❌ | Nicht vorbereitet – Pipeline generiert Artefakte als GitHub-Actions-Artifacts |
| `Dokumentation/` | ❌ | Keine vollständige Dokumentation vorhanden |
| `Certificate Authority/` | ⚠️ | Certs werden via `make generate-certs` erzeugt, aber `rootCA.pem`/`tls.crt` im Git gelöscht |
| `Threat Modelling/` | ❌ | Kein DFD, keine STRIDE-Tabelle, kein Attack Tree |
| Repository als .zip | ❌ | Nicht beigelegt |

### Bewertung SCOPE 6

**Geschätzte Punkte: ~8/15** – Das Makefile ist excellent (5/5). Repo-Struktur fast vollständig (3.5/5, –1.5 für evidence/ und VERSION.txt). ZIP-Abgabe nicht vorbereitet (0/5).

---

## 📝 SCOPE 7 – Dokumentation

| Anforderung | Status | Befund |
|-------------|--------|--------|
| Projektziel klar beschrieben | ✅ | README.md L3-5: präzise Beschreibung |
| Architektur-Schaubild mit Beschriftung | ❌ | **Kein Diagramm.** Kein PNG, SVG, Mermaid oder ASCII-Diagramm. |
| Tech-Stack vollständig | ❌ | Nicht in README. Python/Flask/PostgreSQL/Tailwind/Docker/K8s/Cosign/Syft/Bandit/gitleaks nicht als Liste dokumentiert. |
| Beschreibung aller Komponenten | ❌ | Keine Komponentenbeschreibung. README springt direkt zu Security Requirements. |
| Threat Modeling (DFD, STRIDE, Attack Tree) | ❌ | **Vollständig fehlend.** `docs/` enthält nur `local-dev.md`. |
| Security-Features erklärt mit Verweis | ✅ | SR-01 bis SR-05 mit "Was", "Umsetzung", "Nutzen" + Code-Verweis. |
| Nicht-sichere Parts / Abweichungen | ❌ | Keine Sektion für bekannte Lücken oder Vereinfachungen. |
| Deployment-Prozess (CI/CD) Schritt für Schritt | ❌ | cicd.yml existiert, ist aber nicht als menschenlesbarer Guide dokumentiert. |
| Lessons Learned | ❌ | Keine Retrospektive vorhanden. |

**Konsistenz-Checks:**
- SR-01 bis SR-05: ✅ In README dokumentiert UND im Code implementiert
- CI/CD Pipeline: ⚠️ Implementiert (cicd.yml), aber nicht in Dokumentation beschrieben
- K8s-Security-Features: ⚠️ Vollständig implementiert, aber nicht in README erwähnt

### Bewertung SCOPE 7

**Geschätzte Punkte: ~2/8** – Nur Projektziel (✅) und Security Requirements (✅) erfüllt. Alle anderen Anforderungen fehlen.

---

## Kritische Lücken – Priorisierte Handlungsempfehlungen

### 🔴 Kritisch (Prüfungsrelevant)

1. **Kein Architekturdiagramm** (betrifft Scope 1, 7)
   - Erstelle ein Diagramm mit: Browser → Ingress (TLS) → Flask-Backend → PostgreSQL; K8s-Namespace mit Pods/Services; CI/CD-Pipeline-Schritte
   - Tool-Empfehlung: draw.io, Mermaid (in Markdown einbettbar), oder PlantUML

2. **Kein Threat Modeling** (betrifft Scope 2 komplett – 15 Punkte)
   - **DFD erstellen:** Datenflüsse: Browser→Ingress (HTTPS), Ingress→Flask (HTTP intern), Flask→PostgreSQL (SQL), CI-Runner→GitHub (Git-Push)
   - **STRIDE-Tabelle:** Mindestens Tampering (Input-Validierung), Information Disclosure (Error-Handling), DoS (Rate-Limiting) – Code-Stellen sind bereits vorhanden
   - **Attack Tree:** Worst-Case "DB-Übernahme durch SQL-Injection" – 3 Ebenen, Gegenmaßnahmen verweisen auf app.py

3. **Kein Deploy-Job in Pipeline** (betrifft Scope 4)
   - Kommentare in `cicd.yml:209-223` müssen aktiviert oder durch K8s-Deploy ergänzt werden
   - Minimalvariante: Deploy zu Minikube via `kubectl apply` nach erfolgreichem Quality Gate

### 🟡 Wichtig

4. **README.md unvollständig** (betrifft Scope 6, 7)
   - Muss ergänzt werden um: Architektur-Schaubild, Tech-Stack-Tabelle, Deployment-Guide, Lessons Learned

5. **`/evidence/`-Verzeichnis fehlt** (betrifft Scope 6)
   - `git mkdir` für `evidence/sbom/`, `evidence/sast/`, `evidence/sca/`, `evidence/secrets/`, `evidence/signing/`, `evidence/run/`
   - `.gitkeep`-Dateien anlegen (Artefakte selbst sind gitignored, Struktur muss aber sichtbar sein)

6. **`VERSION.txt` fehlt** (betrifft Scope 6)
   - Erstelle `VERSION.txt` mit einer Versionsangabe (z. B. `1.0.0`)

7. **Zertifikate aus Git-History entfernen** (betrifft Scope 3)
   - `rootCA.pem` und `tls.crt` waren im Initial-Commit. Bereinigung via `git filter-branch` oder BFG Repo-Cleaner empfohlen.

### 🟢 Verbesserungen

8. **SBOM vom Container-Image** (betrifft Scope 4)
   - In cicd.yml: SBOM-Generierung nach `build`-Job verschieben, `syft docker:jukebox:latest` statt `syft dir:.`

9. **Base-Image Digest** (betrifft Scope 4)
   - `Dockerfile:2`: `FROM python:3.11-slim@sha256:<digest>` statt nur Tag

10. **Testfälle für Security Requirements** (betrifft Scope 1)
    - Je SR mindestens einen `curl`-Befehl oder manuellen Test in README dokumentieren

---

## Bewertungsübersicht

| Scope | Bereich | Max | Geschätzt | Fehlende Punkte (Hauptursachen) |
|-------|---------|:---:|:---------:|--------------------------------|
| 1 | Anforderungen & Architektur | 15 | ~8 | Kein Diagramm (–5), keine Tests für SRs (–2) |
| 2 | Threat Modeling | 15 | ~1 | Kein DFD, keine STRIDE-Tabelle, kein Attack Tree (–14) |
| 3 | Secure Coding & App-Security | 15 | ~12 | Cert-History (–1), kein RBAC (–1), kein Bonus |
| 4 | CI/CD-Pipeline | 25 | ~17 | Kein Deploy-Job (–5), SBOM-Quelle (–2), kein Digest (–1) |
| 5 | Kubernetes Security | 15 | ~15 | Keine Abzüge |
| 6 | Abgabe & Reproduzierbarkeit | 15 | ~8 | evidence/-Dir fehlt (–1), VERSION.txt (–1), ZIP (–5) |
| 7 | Dokumentation | 8 | ~2 | Kein Architekturdiagramm, kein Threat Modeling, kein Tech-Stack, keine Deployment-Docs (–6) |
| **Σ** | **Gesamt** | **100** | **~63** | **Hauptlücke: Dokumentation (Scope 2 + 7)** |

---

> **Fazit:** Die technische Implementierung (insbesondere K8s-Security, Authentifizierung, Input-Validierung und CI/CD-Quality-Gates) ist auf hohem Niveau. Der kritische Schwachpunkt liegt in der **vollständig fehlenden Threat-Modeling-Dokumentation** und dem **fehlenden Architekturdiagramm**. Diese lassen sich ohne Code-Änderungen nachliefern und würden die Gesamtbewertung erheblich verbessern.
