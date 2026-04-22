# Terminal Setup Guide — GitHub Actions + Docker Hub CI Pipeline
## Complete Step-by-Step from Scratch Using Only Terminal

---

## Credentials

| Credential | Value |
|---|---|
| GitHub Username | `niharikakanakala` |
| GitHub PAT | `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` |
| GitHub Repo | `Dummy` |
| Docker Hub Username | `niharika13` |
| Docker Hub Repo | `niha_test` |
| Docker Hub Token | `dckr_pat_Ltp8Ctx1Qs2yG4xxNwmUkwaUyT4` |

---

## Step 1 — Configure Git with Your GitHub Identity

```bash
git config --global user.name "niharikakanakala"
git config --global user.email "niharikakanakala@gmail.com"
```

---

## Step 2 — Create Project Folder and Initialize Git

```bash
mkdir my-project
cd my-project
git init
git branch -M main
```

---

## Step 3 — Create the Application File

```bash
cat > hello.sh << 'EOF'
#!/bin/bash
echo "Hello from Dockerized Bash App!"
echo "Build triggered by GitHub Actions CI Pipeline"
echo "Date: $(date)"
EOF
```

---

## Step 4 — Create the Dockerfile

```bash
cat > Dockerfile << 'EOF'
FROM bash:5.2
WORKDIR /app
COPY hello.sh .
RUN chmod +x hello.sh
CMD ["bash", "hello.sh"]
EOF
```

---

## Step 5 — Create the GitHub Actions Workflow

```bash
mkdir -p .github/workflows

cat > .github/workflows/docker-build-push.yml << 'EOF'
name: Build and Push Docker Image

on:
  push:
    branches:
      - main

jobs:
  build-and-push:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            niharika13/niha_test:latest
            niharika13/niha_test:${{ github.sha }}
EOF
```

---

## Step 6 — Commit All Files

```bash
git add .
git commit -m "Add app, Dockerfile, and CI pipeline"
```

---

## Step 7 — Connect to GitHub Repo and Push

```bash
git remote add origin https://github.com/niharikakanakala/Dummy.git

git push https://niharikakanakala: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@github.com/niharikakanakala/Dummy.git main
```

---

## Step 8 — Login to GitHub CLI and Add Docker Hub Secrets

```bash
echo "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" | gh auth login --with-token

gh secret set DOCKERHUB_USERNAME --body "niharika13" --repo niharikakanakala/Dummy

gh secret set DOCKERHUB_TOKEN --body "dckr_pat_Ltp8Ctx1Qs2yG4xxNwmUkwaUyT4" --repo niharikakanakala/Dummy
```

---

## Step 9 — Verify Secrets Were Added

```bash
gh secret list --repo niharikakanakala/Dummy
```

Expected output:
```
DOCKERHUB_TOKEN      2026-04-22T...
DOCKERHUB_USERNAME   2026-04-22T...
```

---

## Step 10 — Trigger the Pipeline

```bash
echo "triggering first pipeline run" >> readme.md
git add readme.md
git commit -m "Trigger CI pipeline"
git push https://niharikakanakala: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@github.com/niharikakanakala/Dummy.git main
```

---

## Step 11 — Monitor the Pipeline Run

```bash
gh run list --repo niharikakanakala/Dummy
```

---

## Step 12 — Check Logs if Pipeline Fails

```bash
gh run view RUN_ID --repo niharikakanakala/Dummy --log-failed
```

---

## Full Flow Summary

```
Terminal: git push origin main
          |
          v
GitHub Actions triggers automatically
          |
          v
Runner checks out code
          |
          v
Logs in to Docker Hub using secrets
          |
          v
Builds Docker image from Dockerfile
          |
          v
Tags image as:
  niharika13/niha_test:latest
  niharika13/niha_test:<commit-sha>
          |
          v
Pushes image to Docker Hub
          |
          v
Image live at: https://hub.docker.com/r/niharika13/niha_test
```

---

## Common Mistake to Avoid

When generating the Docker Hub token, always select **Read, Write, Delete**.
Read-only tokens will fail at the push step with:
```
ERROR: unauthorized: access token has insufficient scopes
```

---

## Quick Reference

```bash
# Push code
git push https://niharikakanakala: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@github.com/niharikakanakala/Dummy.git main

# Check pipeline status
gh run list --repo niharikakanakala/Dummy

# View failed logs
gh run view RUN_ID --repo niharikakanakala/Dummy --log-failed

# Update a secret
gh secret set SECRET_NAME --body "new_value" --repo niharikakanakala/Dummy

# List secrets
gh secret list --repo niharikakanakala/Dummy
```

---

## Verify Results

- GitHub Actions: https://github.com/niharikakanakala/Dummy/actions
- Docker Hub Tags: https://hub.docker.com/r/niharika13/niha_test/tags
