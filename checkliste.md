# ✅ Checkliste: Security by Design – Prüfungsleistung STG-TINF23F

> **Gruppe:** \_\_\_\_\_\_\_\_\_\_\_\_  
> **Abgabedatum:** \_\_\_\_\_\_\_\_\_\_\_\_  
> **Repository:** \_\_\_\_\_\_\_\_\_\_\_\_  

---

## 📋 Legende

| Symbol | Bedeutung |
|--------|-----------|
| ⬜ | Offen |
| 🔄 | In Arbeit |
| ✅ | Abgeschlossen |
| ⚠️ | Abweichung mit Begründung dokumentiert |
| 🔗 | Verbindungs- / Funktionstest – muss aktiv geprüft werden |

> **Hinweis zu 🔗-Checks:** Diese Punkte sind keine Dokumentationsaufgaben, sondern aktive Tests.  
> Sie beweisen, dass Komponenten **wirklich zusammenarbeiten** – nicht nur vorhanden sind.

---

## 🏗️ SCOPE 1 – Anforderungen & Architektur `(15 Punkte)`

### 1.1 Projektdefinition
- [ ] Projektidee festgelegt und beschrieben
- [ ] Programmiersprachen für Frontend definiert
- [ ] Programmiersprachen für Backend definiert
- [ ] Rollen im System definiert (z. B. Admin, User, Service)

### 1.2 Security Requirements

- [ ] Mindestens **5 Security Requirements** definiert
- [ ] Jedes Requirement ist **prüfbar** formuliert (konkret, nicht vage wie „die App soll sicher sein")
- [ ] Jedes Requirement hat eine **eindeutige ID** (z. B. `SR-01` bis `SR-05`) für Rückverfolgbarkeit
- [ ] Jedes Requirement ist auf eine konkrete Komponente oder einen Datenfluss bezogen

#### 🔗 Verbindungstest: Requirements ↔ Implementierung
- [ ] Für jedes Requirement: konkreter Verweis auf die umgesetzte Stelle im Code / Manifest / Konfiguration vorhanden (z. B. Dateiname + Zeile oder Ticket-Nummer)
- [ ] Für jedes Requirement: mindestens ein **Test oder Nachweis** definiert, der zeigt, dass es erfüllt ist (manueller Test, automatischer Test oder Scan-Ergebnis)
- [ ] Kein Requirement hängt „in der Luft" – alle sind vollständig oder mit begründeter Abweichung dokumentiert

### 1.3 Architekturdiagramm

- [ ] Architekturdiagramm erstellt
- [ ] Alle Komponenten eingezeichnet: Frontend, Backend, Datenbank, Ingress, CA
- [ ] Nutzer:innen als externer Akteur eingezeichnet
- [ ] CI/CD-Pipeline mit allen Schritten im Diagramm abgebildet
- [ ] Kubernetes-Cluster mit Namespace, Pods, Service, Ingress abgebildet

#### 🔗 Verbindungstest: Diagramm ↔ Realität
- [ ] Jede Komponente im Diagramm existiert auch als Datei, Manifest oder Service im Repository
- [ ] Kein Dienst/Container läuft in der Praxis, der nicht im Diagramm eingezeichnet ist
- [ ] Jede Verbindungslinie im Diagramm entspricht einem tatsächlichen Netzwerk- oder API-Aufruf (prüfbar z. B. mit `kubectl get svc`, `curl`, Logs)
- [ ] Die Pipeline-Schritte im Diagramm entsprechen 1:1 den definierten Jobs/Steps in der Pipeline-Konfigurationsdatei

---

## 🔍 SCOPE 2 – Threat Modeling `(15 Punkte)`

### 2.1 Systemmodell & DFD

- [ ] Data Flow Diagram (DFD) erstellt
- [ ] Alle Datenflüsse mit Richtung und Protokoll beschriftet (z. B. `HTTPS`, `JWT`, `SQL`)
- [ ] Vertrauensgrenzen (Trust Boundaries) klar eingezeichnet und benannt
- [ ] Externe Entitäten (Nutzer:in, Browser, CI-Runner) eindeutig markiert

#### 🔗 Verbindungstest: DFD ↔ Architekturdiagramm
- [ ] Jede Komponente aus dem Architekturdiagramm (Scope 1.3) taucht auch im DFD auf
- [ ] Jeder Datenfluss im DFD ist einem konkreten API-Endpunkt oder Protokoll zugeordnet
- [ ] Alle Vertrauensgrenzen im DFD sind auch im STRIDE-Threat-Modell referenziert (kein „toter" Trust Boundary)

### 2.2 STRIDE-Bedrohungsanalyse

- [ ] STRIDE-Analyse für **jede Komponente** durchgeführt
- [ ] STRIDE-Analyse für **jeden Datenfluss, der eine Vertrauensgrenze überschreitet**, durchgeführt
- [ ] Mindestens **eine Tabelle** im Vorlesungsformat verwendet (Bedrohung | Komponente/Fluss | Gegenmaßnahme | Status)
- [ ] Mindestens **3 der 6 STRIDE-Kategorien** implementiert oder teilweise implementiert:
  - [ ] **S**poofing – Status: \_\_\_\_\_\_  
    → Gegenmaßnahme: \_\_\_\_\_\_ (z. B. JWT-Validierung, mTLS)
  - [ ] **T**ampering – Status: \_\_\_\_\_\_  
    → Gegenmaßnahme: \_\_\_\_\_\_ (z. B. HMAC, Input-Validierung)
  - [ ] **R**epudiation – Status: \_\_\_\_\_\_  
    → Gegenmaßnahme: \_\_\_\_\_\_ (z. B. Audit-Log, signierte Tokens)
  - [ ] **I**nformation Disclosure – Status: \_\_\_\_\_\_  
    → Gegenmaßnahme: \_\_\_\_\_\_ (z. B. Fehlerbehandlung, TLS)
  - [ ] **D**enial of Service – Status: \_\_\_\_\_\_  
    → Gegenmaßnahme: \_\_\_\_\_\_ (z. B. Rate Limiting, Resource Limits)
  - [ ] **E**levation of Privilege – Status: \_\_\_\_\_\_  
    → Gegenmaßnahme: \_\_\_\_\_\_ (z. B. RBAC, Least Privilege)
- [ ] Für die **3 nicht umgesetzten** Kategorien: nachvollziehbare, technisch begründete Dokumentation

#### 🔗 Verbindungstest: STRIDE ↔ Implementierung
- [ ] Jede **implementierte** Gegenmaßnahme ist im Code/Manifest auffindbar (konkreter Datei-/Funktionsverweis)
- [ ] Gegenmaßnahmen gegen **Spoofing** (z. B. Auth): Manueller Test – Zugriff auf geschützte Route **ohne** Token liefert `401`/`403`, nicht `200`
- [ ] Gegenmaßnahmen gegen **Tampering** (z. B. Input-Validierung): Manueller Test – manipulierter Request (z. B. negativer Betrag, SQL-Injection-Payload) wird vom Backend **abgelehnt**
- [ ] Gegenmaßnahmen gegen **Information Disclosure** (z. B. Fehlerbehandlung): Manueller Test – ein gezielt provozierter `500`-Fehler gibt **keinen** Stack Trace oder DB-Fehlertext zurück

### 2.3 Attack Tree

- [ ] „Worst Case"-Szenario klar benannt (z. B. „vollständige Übernahme der Datenbank")
- [ ] Attack Tree mit mindestens 3 Ebenen (Ziel → Angriffspfade → Einzelschritte)
- [ ] Jedes Blatt hat mindestens eine definierte **Gegenmaßnahme**
- [ ] Gegenmaßnahmen aus dem Attack Tree decken sich mit den in STRIDE beschriebenen Maßnahmen (keine Widersprüche)

#### 🔗 Verbindungstest: Attack Tree ↔ Implementierung
- [ ] Für das Worst-Case-Szenario: mindestens **zwei Angriffspfade** im Attack Tree sind durch konkrete technische Maßnahmen im Projekt **tatsächlich blockiert** (mit Nachweis)
- [ ] Kein Angriffsblatt, das als „mitigiert" markiert ist, ist im Projekt ohne Gegenmaßnahme umgesetzt

---

## 💻 SCOPE 3 – Secure Coding & App-Security `(15 + 10 Punkte)`

### 3.1 Fehlerbehandlung

- [ ] Alle API-Endpunkte haben eine Fehlerbehandlung (try/catch oder äquivalent)
- [ ] Fehlermeldungen nach außen sind **generisch** (keine Datenbankfehler, Stack Traces, Dateipfade)
- [ ] Interne Fehler werden **geloggt**, aber nicht an den Client gesendet

#### 🔗 Verbindungstest: Fehlerbehandlung
- [ ] Test: HTTP-Request an nicht existierende Route → Antwort ist `404` ohne interne Details
- [ ] Test: Absichtlich fehlerhafter Request (z. B. ungültiger JSON-Body) → Antwort ist `400` ohne Stack Trace
- [ ] Test: Direkte DB-Fehler provozieren (z. B. ungültiger Datenbankwert) → keine DB-Fehlermeldung im Response-Body sichtbar

### 3.2 Eingabevalidierung

- [ ] **Backend**: Alle eingehenden Request-Parameter (Query, Body, Header) werden validiert
- [ ] **Frontend**: Pflichtfelder und Formatprüfung vor dem Absenden
- [ ] Validierungslogik liegt **im Backend** (Frontend-Validierung ist nur UX, kein Sicherheitsmerkmal)
- [ ] Verwendete Bibliothek oder eigene Validierungslogik dokumentiert

#### 🔗 Verbindungstest: Eingabevalidierung
- [ ] Test: SQL-Injection-Payload im Eingabefeld → Backend lehnt ab (`400`) oder escaped korrekt, kein DB-Fehler
- [ ] Test: Extrem langes String-Feld (z. B. 10.000 Zeichen) → Backend lehnt ab oder schneidet sauber ab
- [ ] Test: Ungültiger Datentyp (z. B. String statt Integer) → Backend gibt validen Fehler zurück
- [ ] Test: Leere Pflichtfelder → Backend lehnt ab, keine `500`-Fehler

### 3.3 Authentifizierung & Autorisierung

- [ ] Anmeldung (Login) implementiert mit sicherer Passwort-Verarbeitung (z. B. bcrypt, argon2 – kein MD5/SHA1)
- [ ] Session-/Token-Management implementiert (z. B. JWT, Session-Cookie mit `HttpOnly` + `Secure`)
- [ ] Alle schützenswerten Routen/Endpunkte sind durch Auth-Middleware gesichert
- [ ] Rollenbasierte Zugriffskontrolle (falls mehrere Rollen vorhanden) implementiert
- [ ] **Optional (Bonus):** SSO implementiert
- [ ] **Optional (Bonus):** MFA implementiert

#### 🔗 Verbindungstest: Auth
- [ ] Test: Geschützter Endpunkt ohne Token aufrufen → `401 Unauthorized`
- [ ] Test: Geschützter Endpunkt mit **abgelaufenem** Token aufrufen → `401`, kein Zugriff
- [ ] Test: Geschützter Endpunkt mit **manipuliertem** Token (z. B. Payload Base64-verändert) → `401`
- [ ] Test (falls Rollen): User mit Rolle A versucht Aktion von Rolle B → `403 Forbidden`
- [ ] Test: Login mit falschem Passwort → `401`, kein Hinweis, welches Feld falsch war

### 3.4 Secret-Hygiene

- [ ] Keine Passwörter, API-Keys, Tokens oder Private Keys im Repository committed (auch nicht in der History)
- [ ] Secrets werden über **Umgebungsvariablen oder Kubernetes Secrets** bereitgestellt
- [ ] `.gitignore` enthält alle relevanten Secret-Dateien (`.env`, `*.key`, `*.pem` etc.)

#### 🔗 Verbindungstest: Secret-Hygiene
- [ ] Test: `git log --all -S "password"` liefert **keine** Treffer mit echten Credentials
- [ ] Test: Anwendung startet korrekt, wenn Secrets **ausschließlich** über Env-Variablen gesetzt werden (keine Fallback-Hardcodes)
- [ ] Test: Secret-Scan in der Pipeline schlägt an, wenn testweise ein Dummy-Secret (z. B. `AWS_SECRET=AKIAIOSFODNN7EXAMPLE`) eingecheckt wird → Pipeline bricht ab

### 3.5 TLS-Readiness

- [ ] Eigene Certificate Authority (CA) aufgesetzt
- [ ] TLS-Zertifikat von der eigenen CA ausgestellt und signiert
- [ ] Zertifikat im Kubernetes-Ingress oder direkt in der Anwendung eingebunden
- [ ] HTTP-Traffic wird auf HTTPS umgeleitet (kein unverschlüsselter Betrieb möglich)

#### 🔗 Verbindungstest: TLS
- [ ] Test: `curl -v https://<hostname>` mit `--cacert rootCA.pem` → TLS-Handshake erfolgreich, Zertifikat valide
- [ ] Test: `openssl verify -CAfile rootCA.pem <cert>.pem` → Ausgabe `OK`
- [ ] Test: `curl http://<hostname>` → Redirect auf HTTPS oder direkte Ablehnung (`301`/`400`)
- [ ] Test: `openssl s_client -connect <hostname>:443` → Zertifikatskette zeigt die eigene CA als Root

---

## 🔄 SCOPE 4 – CI/CD-Pipeline `(25 Punkte)`

> **Trigger:** Jeder Push/Merge auf den `main`-Branch löst die Pipeline **automatisch** aus.

### 4.1 Pipeline-Trigger

- [ ] Pipeline-Trigger auf `main`-Branch konfiguriert (z. B. `on: push: branches: [main]`)
- [ ] Kein manueller Schritt notwendig, um die Pipeline zu starten

#### 🔗 Verbindungstest: Trigger
- [ ] Test: Dummy-Commit auf `main` pushen → Pipeline startet **automatisch** ohne manuellen Eingriff
- [ ] Test: Commit auf Feature-Branch pushen → Pipeline startet **nicht** (nur main triggert)

### 4.2 Schritt-Reihenfolge & Abhängigkeiten

Die Pipeline muss in dieser **logischen Reihenfolge** ablaufen:

```
[1] SBOM erstellen
[2] SAST + SCA + Secret Scan
[3] Build + Container-Build
[4] Image Signing
[5] Quality Gate (Auswertung aller vorherigen Schritte)
[6] Deploy → Kubernetes
```

- [ ] Schritte 1–4 laufen **vor** dem Quality Gate
- [ ] Deploy (Schritt 6) läuft **nur**, wenn das Quality Gate (Schritt 5) erfolgreich war
- [ ] Schritt-Abhängigkeiten sind explizit in der Pipeline-Konfiguration definiert (z. B. `needs:`)

#### 🔗 Verbindungstest: Reihenfolge
- [ ] Test: Prüfen in den Pipeline-Logs, dass Deploy-Step erst **nach** dem Quality-Gate-Step startet
- [ ] Test: Quality Gate absichtlich scheitern lassen (z. B. Dummy-Secret einchecken) → Deploy-Step wird **übersprungen/nicht ausgeführt**

### 4.3 SBOM-Erzeugung

- [ ] SBOM wird automatisch nach dem Build erzeugt (z. B. mit Syft, CycloneDX-CLI)
- [ ] SBOM referenziert das **gerade gebaute Image** (nicht ein altes)
- [ ] SBOM-Format dokumentiert (z. B. CycloneDX JSON, SPDX)
- [ ] SBOM-Bericht wird als Artefakt gespeichert und in `/evidence/<image>/sbom/` abgelegt

#### 🔗 Verbindungstest: SBOM
- [ ] Test: SBOM-Datei öffnen und prüfen, ob der darin referenzierte Image-Digest mit dem tatsächlich gebauten Image (`docker inspect --format='{{index .RepoDigests 0}}'`) übereinstimmt
- [ ] Test: SBOM enthält mindestens alle direkten Abhängigkeiten des Projekts (Stichprobe: eine bekannte Dependency suchen)

### 4.4 SAST / SCA / Secret Scan

- [ ] **SAST**-Tool integriert (z. B. Semgrep, Bandit, SpotBugs)
- [ ] **SCA**-Tool integriert (z. B. Trivy, OWASP Dependency-Check, Grype)
- [ ] **Secret Scan**-Tool integriert (z. B. Gitleaks, truffleHog)
- [ ] Jedes Tool speichert seinen Bericht in dem entsprechenden `/evidence/`-Unterordner
- [ ] Alle drei Tools laufen **auf dem selben Codestand** wie der Build

#### 🔗 Verbindungstest: SAST/SCA/Secret Scan
- [ ] Test SAST: Eine bekannte unsichere Code-Pattern einbauen (z. B. `eval()`, hardcoded IP) → SAST schlägt an und erzeugt Finding
- [ ] Test SCA: Eine Abhängigkeit mit bekannter CVE ≥ 7.0 einfügen → SCA-Bericht enthält dieses Finding
- [ ] Test Secret Scan: Dummy-Secret einchecken (kein echtes!) → Secret Scan schlägt an
- [ ] Berichte aus `/evidence/` nachvollziehbar einem konkreten Pipeline-Run zugeordnet (z. B. über Dateiname mit Run-ID oder Timestamp)

### 4.5 Build & Container-Build

- [ ] Anwendung wird in der Pipeline gebaut (kein pre-built Binary eingecheckt)
- [ ] Container-Image wird in der Pipeline gebaut
- [ ] Dockerfile ist **sicher** konfiguriert:
  - [ ] Kein `USER root` als finale Anweisung
  - [ ] Kein `COPY . .` ohne `.dockerignore` (keine Secrets ins Image kopieren)
  - [ ] Base Image mit konkreter Version/Digest gepinnt (kein `latest`)
  - [ ] Minimales Base-Image verwendet (z. B. `distroless`, `alpine`)

#### 🔗 Verbindungstest: Container-Build
- [ ] Test: `docker run --rm <image> whoami` → Ausgabe ist **nicht** `root`
- [ ] Test: `docker inspect <image>` → Image enthält keine Secrets (keine `.env`-Dateien, keine Private Keys)
- [ ] Test: `docker history <image>` → keine sensiblen Werte (Passwörter, Tokens) in Build-Argumenten sichtbar

### 4.6 Image Signing

- [ ] Container-Image wird nach dem Build signiert (z. B. mit Cosign)
- [ ] Signing-Schlüsselpaar generiert und Public Key gespeichert
- [ ] `image.sig` oder `image.bundle` im `/evidence/`-Ordner gespeichert

#### 🔗 Verbindungstest: Image Signing
- [ ] Test: `cosign verify --key <public.key> <image-ref>` → Verifikation erfolgreich, kein Fehler
- [ ] Test: Signatur entfernen/verändern und erneut verifizieren → Verifikation **schlägt fehl**
- [ ] Test: Ein **unsigniertes** Image durch den Quality Gate schicken → Pipeline bricht ab (siehe 4.7)
- [ ] Der im Quality Gate verwendete Public Key ist identisch mit dem in `/evidence/` gespeicherten

### 4.7 Quality Gate

Das Quality Gate **muss die Pipeline aktiv abbrechen** (Exit-Code ≠ 0), nicht nur warnen.

- [ ] **Abbruch bei gefundenen Secrets** – Pipeline-Job endet mit Fehler, wenn Secret Scan Findings hat
- [ ] **Abbruch bei CVSS ≥ 7.0** – Pipeline-Job endet mit Fehler bei HIGH/CRITICAL Findings aus SCA/SAST
- [ ] **Abbruch bei fehlender/ungültiger Signatur** – Pipeline-Job endet mit Fehler, wenn `cosign verify` fehlschlägt
- [ ] Die Bedingungen sind **nicht manuell umgehbar** (kein `continue-on-error: true` oder äquivalent)

#### 🔗 Verbindungstest: Quality Gate (alle drei Abbruchbedingungen einzeln testen!)
- [ ] **Test 1 – Secret:** Dummy-Secret einchecken → Quality Gate bricht ab, **Deploy-Step wird nicht ausgeführt** (in Logs nachweisbar)
- [ ] **Test 2 – CVSS:** Abhängigkeit mit bekannter HIGH/CRITICAL CVE einführen → Quality Gate bricht ab, kein Deploy
- [ ] **Test 3 – Signatur:** Unsigned Image oder manipulierte Signatur → Quality Gate bricht ab, kein Deploy
- [ ] Für alle drei Tests: Pipeline-Logs als **Evidence** in `/evidence/<image>/run/` gespeichert

### 4.8 Deployment nach Kubernetes

- [ ] Container-Image wird **nach erfolgreichem Quality Gate** in Kubernetes deployed
- [ ] Deployment-Weg dokumentiert (Container-Registry oder direkt)
- [ ] Bei Nutzung einer Registry: Pull-Secret in Kubernetes konfiguriert

#### 🔗 Verbindungstest: Deployment
- [ ] Test: Nach erfolgreichem Pipeline-Run → `kubectl get pods -n <namespace>` zeigt Pod im Status `Running`
- [ ] Test: `kubectl describe pod <pod>` → Image-Digest stimmt mit dem signierten Image aus dem Pipeline-Run überein
- [ ] Test: Anwendung über Ingress erreichbar → `curl -k https://<hostname>/health` gibt `200` zurück

---

## ☸️ SCOPE 5 – Kubernetes Security `(15 Punkte)`

### 5.1 Namespace & Service Account

- [ ] Eigener **Namespace** angelegt (nicht `default`)
- [ ] Eigener **Service Account** angelegt (nicht `default`)
- [ ] Service Account hat **keine** ClusterRoleBindings außer wenn explizit begründet
- [ ] Service Account ist im Deployment-Manifest referenziert (`serviceAccountName`)

#### 🔗 Verbindungstest: Namespace & SA
- [ ] Test: `kubectl get rolebindings,clusterrolebindings -n <namespace>` → SA hat nur minimal notwendige Rechte
- [ ] Test: `kubectl auth can-i list secrets --as=system:serviceaccount:<namespace>:<sa>` → `no`
- [ ] Test: Pod läuft tatsächlich unter dem eigenen SA: `kubectl get pod <pod> -o jsonpath='{.spec.serviceAccountName}'`

### 5.2 Security Context

- [ ] `runAsNonRoot: true` im Pod/Container-Spec gesetzt
- [ ] `readOnlyRootFilesystem: true` gesetzt
- [ ] `allowPrivilegeEscalation: false` gesetzt
- [ ] `capabilities.drop: ["ALL"]` gesetzt
- [ ] Falls die Anwendung in ein Verzeichnis schreiben muss: `emptyDir`-Volume gemountet (kein Rootfilesystem)

#### 🔗 Verbindungstest: Security Context
- [ ] Test: `kubectl exec -it <pod> -- whoami` → Ausgabe ist **nicht** `root`
- [ ] Test: `kubectl exec -it <pod> -- touch /test.txt` → Fehler wegen `readOnlyRootFilesystem`
- [ ] Test: `kubectl get pod <pod> -o jsonpath='{.spec.containers[0].securityContext}'` → alle vier Felder korrekt gesetzt
- [ ] Test: Pod startet überhaupt noch fehlerfrei mit allen Security-Context-Einschränkungen (keine CrashLoopBackOff)

### 5.3 Network Policy

- [ ] Network Policy im richtigen Namespace angelegt
- [ ] **Ingress-Traffic** auf notwendige Ports beschränkt (z. B. nur Port 443 vom Ingress-Controller)
- [ ] Egress-Traffic definiert (auch wenn nur ein Allow-All als Basis mit begründeter Einschränkung)
- [ ] Network Policy ist dem richtigen Pod zugeordnet (korrekte `podSelector`-Labels)

#### 🔗 Verbindungstest: Network Policy
- [ ] Test: `kubectl run test-pod --image=alpine -n <namespace> -- sh -c "wget -qO- http://<app-service>:<port>"` → Verbindung wird von Network Policy **erlaubt** (gewollter Traffic funktioniert)
- [ ] Test: Von einem Pod in einem **anderen Namespace** versuchen, die App direkt anzusprechen → Verbindung **schlägt fehl** (Network Policy blockiert)
- [ ] Test: `kubectl get networkpolicy -n <namespace>` → Policy vorhanden und korrekt benannt
- [ ] Test: `kubectl describe networkpolicy <name> -n <namespace>` → Ingress-Regeln entsprechen der Dokumentation

---

## 📦 SCOPE 6 – Abgabe & Reproduzierbarkeit `(15 Punkte)`

### 6.1 Repository-Struktur

- [ ] Repository ist **privat**, Dozent als Maintainer eingetragen
- [ ] `/frontend/` vorhanden
- [ ] `/backend/` vorhanden
- [ ] `/infrastructure/k8s/` (Manifeste oder Helm Charts) vorhanden
- [ ] Pipeline-Konfigurationsverzeichnis vorhanden
- [ ] `/evidence/` mit Unterordnern: `run/`, `sast/`, `sbom/`, `sca/`, `secrets/`, `signing/`
- [ ] `VERSION.txt` vorhanden
- [ ] `README.md` mit ausführlichem Setup-Guide vorhanden
- [ ] `Makefile` vorhanden

### 6.2 Makefile

Das Makefile muss auf einem **frischen System** ohne Vorwissen funktionieren.

- [ ] `make up` implementiert
- [ ] Cluster hochfahren (z. B. `kind create cluster` oder `minikube start`)
- [ ] Namespace anlegen (`kubectl create namespace ...`)
- [ ] Ingress ausrollen
- [ ] Image aus `.tar` laden (`docker load` oder `kind load`)
- [ ] K8s-Manifeste anwenden (`kubectl apply -f ...`)
- [ ] Warten bis alle Pods `Running` und `Ready` sind (z. B. `kubectl wait --for=condition=ready`)
- [ ] `Ready` ausgeben

#### 🔗 Verbindungstest: Makefile & Reproduzierbarkeit
- [ ] Test: `make up` auf einem **sauberen System** (oder frischem Cluster) ausführen → **alles läuft durch ohne manuellen Eingriff**
- [ ] Test: Nach `make up` ist die Anwendung tatsächlich erreichbar (HTTP-Check)
- [ ] Test: README-Setup-Guide von einer fremden Person blind befolgen → erfolgreiches Deployment

### 6.3 ZIP-Abgabe (`team-<nr>.zip`)

- [ ] **`Image/`**: `.tar`-Export des finalen Images, `digest.txt`, Public Key, `image.sig`/`image.bundle`, alle Berichte
- [ ] **`Dokumentation/`**: vollständige Dokumentation (Scope 7)
- [ ] **`Certificate Authority/`**: `rootCA.pem` + ausgestellte Zertifikate
- [ ] **`Threat Modelling/`**: DFD, STRIDE-Tabelle, Attack Tree
- [ ] **Repository als `.zip`** beigelegt

#### 🔗 Verbindungstest: ZIP-Konsistenz
- [ ] Der SHA-256-Digest in `digest.txt` stimmt mit dem Digest des beigelegten `.tar`-Images überein:  
  `sha256sum <image>.tar` → muss mit `digest.txt` übereinstimmen
- [ ] Die Signatur aus `image.sig` / `image.bundle` lässt sich mit dem beigelegten Public Key verifizieren:  
  `cosign verify --key <public.key> --local-image <image>.tar`
- [ ] Die Zertifikate in `Certificate Authority/` wurden von der beigelegten `rootCA.pem` ausgestellt (Kettenprüfung möglich)

---

## 📝 SCOPE 7 – Dokumentation `(8 Punkte)`

- [ ] **Ziel** des Projekts klar beschrieben
- [ ] **Architektur-Schaubild** mit Beschriftung aller Komponenten
- [ ] **Tech-Stack** vollständig (Sprachen, Frameworks, Tools, K8s-Komponenten)
- [ ] **Beschreibung aller Komponenten** aus dem Schaubild
- [ ] **Threat Modeling**: Systemmodell, DFD, STRIDE-Tabelle(n), Attack Tree – alle mit Erklärung
- [ ] **Sicherheitsfeatures**: Jedes Feature erklärt und mit Verweis auf die Implementierung
- [ ] **Nicht-sichere Parts**: Alle bewussten Sicherheitslücken oder Vereinfachungen mit Begründung dokumentiert
- [ ] **Deployment-Prozess**: CI/CD-Pipeline Schritt für Schritt erklärt
- [ ] **Lessons Learned**: Reflexion über Erkenntnisse, Fehler und Verbesserungen

#### 🔗 Konsistenzcheck: Dokumentation ↔ Projekt
- [ ] Kein Sicherheitsfeature ist in der Dokumentation beschrieben, das nicht im Code/Manifest existiert
- [ ] Kein Feature ist implementiert, das nicht in der Dokumentation erwähnt ist (kein „verstecktes" Feature)
- [ ] STRIDE-Tabelle und Attack Tree stimmen mit dem DFD überein (gleiche Komponenten, gleiche Datenflussnamen)
- [ ] Architektur-Schaubild in der Dokumentation ist identisch mit dem im Abgabe-ZIP enthaltenen

---

## 🎤 SCOPE 8 – Präsentation

- [ ] Präsentation vorbereitet (max. 15 Minuten)
- [ ] Demo der laufenden Anwendung vorbereitet (Live-System oder Screenshots mit Nachweis)
- [ ] Alle Kernthemen abgedeckt: Architektur, Threat Modeling, CI/CD-Pipeline, K8s-Security
- [ ] Nachweise für Quality Gate (alle 3 Abbruchbedingungen) als Evidence bereit
- [ ] Termin mit Dozent:in abgestimmt

---

## 🔗 Gesamtübersicht: Kritische Verbindungen

Diese Tabelle zeigt die wichtigsten **End-to-End-Verbindungen** im Projekt. Jede Zeile repräsentiert eine Kette, die vollständig funktionieren muss:

| # | Von | → | Über | → | Nach | Testnachweis |
|---|-----|---|------|---|------|-------------|
| 1 | Git Push auf `main` | → | Pipeline-Trigger | → | Automatischer Pipeline-Start | Pipeline-Log |
| 2 | Source Code | → | SAST/SCA/SecretScan | → | Findings in `/evidence/` | Bericht-Datei |
| 3 | Container-Build | → | Image Signing (Cosign) | → | `image.sig` / `image.bundle` | `cosign verify` OK |
| 4 | Alle Scan-Ergebnisse | → | Quality Gate | → | Pipeline-Abbruch **oder** Deploy | Pipeline-Log |
| 5 | Quality Gate (Pass) | → | Deploy-Step | → | Pod `Running` in K8s | `kubectl get pods` |
| 6 | Image-Digest (Pipeline) | → | `digest.txt` + SBOM | → | ZIP-Abgabe | SHA256-Match |
| 7 | Nutzer-Request | → | Ingress + TLS | → | Backend (Auth-Check) | `curl` mit CA-Cert |
| 8 | Auth-Token | → | Auth-Middleware | → | Geschützte Route | `401` ohne Token |
| 9 | K8s Network Policy | → | Pod-Selector | → | Traffic-Blockierung | `kubectl exec` Test |
| 10 | Security Requirement | → | Implementierung | → | Nachweis / Test | Verweis in Doku |

---

## 📊 Punkteübersicht

| Bereich | Max. Punkte | Erreicht |
|---|---|---|
| Anforderungen & Architektur | 15 | __ |
| Threat Modeling | 15 | __ |
| Secure Coding & App-Security | 15 (+10) | __ |
| CI/CD | 25 | __ |
| Kubernetes Security | 15 | __ |
| Abgabe (Repo + Doku) | 15 | __ |
| **Gesamt** | **100 (110)** | __ |

---

> 💡 **Hinweis:** Abweichungen von den Anforderungen sind zulässig, müssen aber **schlüssig begründet und reflektiert** dokumentiert werden.  
> ⚠️ **Wichtig:** Die 🔗-Verbindungstests sind kein optionaler Bonus – sie zeigen, ob das System **wirklich funktioniert**, nicht nur ob Konfigurationsdateien existieren.