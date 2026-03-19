# Guide: Registry-Push und Image Signing einbinden

Dieses Dokument beschreibt alle Schritte, um nach erfolgreichen Quality Gates das Docker-Image in die GitHub Container Registry (ghcr.io) zu pushen und mit Cosign zu signieren.

---

## Voraussetzungen

- Cosign lokal installiert ([cosign.dev](https://docs.sigstore.dev/cosign/system_config/installation/))
- Zugriff auf das GitHub-Repository (Settings > Secrets)
- GitHub Packages für das Repository aktiviert (Standard bei öffentlichen Repos)

---

## Schritt 1: Cosign-Schlüsselpaar generieren

Lokal ausführen:

```bash
cosign generate-key-pair
```

Das erzeugt zwei Dateien:
- `cosign.key` — privater Schlüssel (geheim, nicht committen)
- `cosign.pub` — öffentlicher Schlüssel (darf ins Repo)

Du wirst nach einem Passwort gefragt — merken, das kommt als Secret rein.

> **Wichtig:** `cosign.key` niemals committen. Am besten sofort in `.gitignore` eintragen.

---

## Schritt 2: GitHub Secrets anlegen

Im GitHub-Repo unter **Settings → Secrets and variables → Actions → New repository secret** folgende drei Secrets anlegen:

| Secret-Name | Inhalt |
|---|---|
| `COSIGN_PRIVATE_KEY` | Inhalt der Datei `cosign.key` (komplett, inkl. Header/Footer) |
| `COSIGN_PASSWORD` | Das Passwort, das bei `generate-key-pair` eingegeben wurde |
| `COSIGN_PUBLIC_KEY` | Inhalt der Datei `cosign.pub` (komplett, inkl. Header/Footer) |

Inhalt einer Datei ausgeben zum Kopieren:

```bash
cat cosign.key
cat cosign.pub
```

---

## Schritt 3: GitHub Packages aktivieren (falls nötig)

Bei öffentlichen Repositories ist ghcr.io automatisch nutzbar. Bei privaten Repos:

- Repository → **Settings → General → Features → Packages** aktivieren

Das `GITHUB_TOKEN` ist in GitHub Actions automatisch vorhanden — kein eigenes Token nötig.

---

## Schritt 4: Pipeline anpassen

In `.github/workflows/cicd.yml` im Job `build-and-verify` die auskommentierten Push-Schritte aktivieren und `<owner>` durch den GitHub-Nutzernamen oder die Organisation ersetzen:

```yaml
- uses: docker/login-action@v2
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}
- run: |
    docker tag jukebox:latest ghcr.io/<owner>/jukebox:latest
    docker push ghcr.io/<owner>/jukebox:latest
```

Außerdem die `permissions` für den Job erweitern (auf Job-Ebene):

```yaml
build-and-verify:
  needs: scan
  runs-on: ubuntu-latest
  permissions:
    contents: read
    packages: write
```

---

## Schritt 5: Signing und Verify in die Pipeline einbauen

Nach dem Push-Schritt im selben Job (oder als separater Job nach `build-and-verify`) Signing hinzufügen:

```yaml
- name: Sign image
  env:
    COSIGN_KEY: ${{ secrets.COSIGN_PRIVATE_KEY }}
    COSIGN_PASSWORD: ${{ secrets.COSIGN_PASSWORD }}
  run: |
    mkdir -p evidence/signing
    echo "$COSIGN_KEY" | tr -d '\r' > cosign.key
    cosign sign --yes --key cosign.key ghcr.io/<owner>/jukebox:latest \
      2>&1 | tee evidence/signing/sign.log
    echo "---" >> evidence/signing/sign.log
    echo "Image:     ghcr.io/<owner>/jukebox:latest" >> evidence/signing/sign.log
    echo "Git SHA:   ${{ github.sha }}" >> evidence/signing/sign.log
    echo "Timestamp: $(date -u)" >> evidence/signing/sign.log
    rm -f cosign.key
```

Für das Verify (Quality Gate) nach dem Signing:

```yaml
- name: Verify image signature
  env:
    COSIGN_PUBLIC_KEY: ${{ secrets.COSIGN_PUBLIC_KEY }}
  run: |
    mkdir -p evidence/signing
    echo "$COSIGN_PUBLIC_KEY" | tr -d '\r' > cosign.pub
    cosign verify --key cosign.pub ghcr.io/<owner>/jukebox:latest \
      2>&1 | tee evidence/signing/verify.log
```

Den `upload-artifact`-Schritt um die Signing-Evidence erweitern:

```yaml
path: |
  evidence/sbom/sbom.json
  evidence/run/run-info.json
  evidence/signing/sign.log
  evidence/signing/verify.log
```

---

## Zusammenfassung der benötigten Secrets

| Secret | Wird gebraucht für |
|---|---|
| `COSIGN_PRIVATE_KEY` | Image signieren |
| `COSIGN_PASSWORD` | Cosign-Key entsperren |
| `COSIGN_PUBLIC_KEY` | Signatur verifizieren (Quality Gate) |

`GITHUB_TOKEN` ist automatisch verfügbar — kein manuelles Secret nötig.

---

## Reihenfolge der fertigen Pipeline-Jobs

```
scan → build-and-verify (inkl. push + sign + verify + trivy)
```

Oder alternativ aufgeteilt:

```
scan → build-and-push → sign → quality-gate (verify + trivy)
```
