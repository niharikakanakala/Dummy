# Terminal Setup Guide — GitHub Actions + Docker Hub CI Pipeline
## Complete Step-by-Step from Scratch Using Only Terminal

---

## Credentials You Need Before Starting

| Credential | Where to Get It | Permission Needed |
|---|---|---|
| GitHub PAT (`ghp_...`) | GitHub → Settings → Developer settings → Personal access tokens (classic) → scope: `repo` | repo (full control) |
| Docker Hub Token (`dckr_pat_...`) | Docker Hub → Account Settings → Personal access tokens → Generate new token | Read, Write, Delete |

---

## Step 1 — Configure Git with Your GitHub Identity

```bash
git config --global user.name "your-github-username"
git config --global user.email "your-email@gmail.com"
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
            YOUR_DOCKERHUB_USERNAME/YOUR_REPO_NAME:latest
            YOUR_DOCKERHUB_USERNAME/YOUR_REPO_NAME:${{ github.sha }}
EOF
```

> Replace `YOUR_DOCKERHUB_USERNAME` and `YOUR_REPO_NAME` with your actual values before pushing.

---

## Step 6 — Commit All Files

```bash
git add .
git commit -m "Add app, Dockerfile, and CI pipeline"
```

---

## Step 7 — Connect to GitHub Repo and Push

```bash
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/YOUR_REPO_NAME.git

git push https://YOUR_GITHUB_USERNAME:YOUR_PAT@github.com/YOUR_GITHUB_USERNAME/YOUR_REPO_NAME.git main
```

> Replace `YOUR_PAT` with your GitHub Personal Access Token (`ghp_...`)

---

## Step 8 — Login to GitHub CLI and Add Docker Hub Secrets

```bash
# Login using your PAT
echo "YOUR_PAT" | gh auth login --with-token

# Add Docker Hub username as a secret
gh secret set DOCKERHUB_USERNAME --body "your_dockerhub_username" --repo YOUR_GITHUB_USERNAME/YOUR_REPO_NAME

# Add Docker Hub token as a secret
gh secret set DOCKERHUB_TOKEN --body "your_dockerhub_token" --repo YOUR_GITHUB_USERNAME/YOUR_REPO_NAME
```

---

## Step 9 — Verify Secrets Were Added

```bash
gh secret list --repo YOUR_GITHUB_USERNAME/YOUR_REPO_NAME
```

Expected output:
```
DOCKERHUB_TOKEN      2026-04-22T...
DOCKERHUB_USERNAME   2026-04-22T...
```

---

## Step 10 — Trigger the Pipeline

Any push to `main` triggers the pipeline automatically:

```bash
echo "triggering first pipeline run" >> readme.md
git add readme.md
git commit -m "Trigger CI pipeline"
git push https://YOUR_GITHUB_USERNAME:YOUR_PAT@github.com/YOUR_GITHUB_USERNAME/YOUR_REPO_NAME.git main
```

---

## Step 11 — Monitor the Pipeline Run

```bash
# List recent workflow runs
gh run list --repo YOUR_GITHUB_USERNAME/YOUR_REPO_NAME

# Watch a specific run live
gh run watch RUN_ID --repo YOUR_GITHUB_USERNAME/YOUR_REPO_NAME
```

---

## Step 12 — Check Logs if Pipeline Fails

```bash
gh run view RUN_ID --repo YOUR_GITHUB_USERNAME/YOUR_REPO_NAME --log-failed
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
  YOUR_DOCKERHUB_USERNAME/YOUR_REPO_NAME:latest
  YOUR_DOCKERHUB_USERNAME/YOUR_REPO_NAME:<commit-sha>
          |
          v
Pushes image to Docker Hub
          |
          v
Image is live on Docker Hub
```

---

## Common Mistake to Avoid

When generating the Docker Hub token, always select **Read, Write, Delete**.
Read-only tokens will fail at the push step with:
```
ERROR: unauthorized: access token has insufficient scopes
```

---

## Quick Reference — Commands You Will Use Most

```bash
# Push code
git push https://USERNAME:PAT@github.com/USERNAME/REPO.git main

# Check pipeline status
gh run list --repo USERNAME/REPO

# View failed logs
gh run view RUN_ID --repo USERNAME/REPO --log-failed

# Update a secret
gh secret set SECRET_NAME --body "new_value" --repo USERNAME/REPO

# List secrets
gh secret list --repo USERNAME/REPO
```
