# CI Pipeline — GitHub Actions + Docker Hub
## Complete Setup Guide with Every Step We Followed

---

## What We Built

A Continuous Integration (CI) pipeline that automatically:
1. Triggers when code is pushed to the `main` branch on GitHub
2. Builds a Docker image from the application source code
3. Tags the Docker image with `latest` and the Git commit SHA
4. Pushes the built image to Docker Hub

---

## Accounts Required

| Account | Purpose | URL |
|---|---|---|
| GitHub | Hosts the source code and runs the CI pipeline | https://github.com |
| Docker Hub | Stores the built Docker images | https://hub.docker.com |

---

## Credentials We Needed

### 1. GitHub Personal Access Token (PAT)
- **What it is:** A token that replaces your GitHub password for terminal operations
- **Why needed:** GitHub removed password authentication for Git in 2021. You must use a PAT to push code from terminal
- **How to generate:**
  1. Go to GitHub → click your profile photo → Settings
  2. Scroll down → Developer settings
  3. Personal access tokens → Tokens (classic)
  4. Click "Generate new token (classic)"
  5. Give it a name (e.g., `terminal-access`)
  6. Select scope: `repo` (full control of private repositories)
  7. Click "Generate token"
  8. Copy the token immediately — it won't be shown again
- **Format:** Starts with `ghp_...`
- **Used for:** Running `git push` from terminal

### 2. Docker Hub Access Token
- **What it is:** A token that allows external services (like GitHub Actions) to push images to Docker Hub
- **Why needed:** GitHub Actions needs to authenticate with Docker Hub to push the built image
- **How to generate:**
  1. Go to Docker Hub → click your username → Account Settings
  2. Click "Personal access tokens" → "Generate new token"
  3. Give it a description (e.g., `github-actions`)
  4. Set Access permissions to: **Read, Write, Delete**
     - NOTE: Read-only will NOT work — the pipeline needs Write permission to push images
  5. Click "Generate"
  6. Copy the token immediately
- **Format:** Starts with `dckr_pat_...`
- **Used for:** GitHub Actions authenticating with Docker Hub during the pipeline run

### 3. GitHub Repository Secrets
- **What they are:** Encrypted variables stored in the GitHub repo, injected into the pipeline at runtime
- **Why needed:** Credentials must never be hardcoded in workflow files — secrets keep them secure
- **How to add:**
  1. Go to your GitHub repo → Settings
  2. Secrets and variables → Actions
  3. Click "New repository secret"
  4. Add the following two secrets:

| Secret Name | Value |
|---|---|
| `DOCKERHUB_USERNAME` | Your Docker Hub username (e.g., `niharika13`) |
| `DOCKERHUB_TOKEN` | Your Docker Hub Access Token (`dckr_pat_...`) |

---

## Files We Created

### 1. `hello.sh` — The Application
A simple bash script acting as the application being containerized:
```bash
#!/bin/bash
echo "Hello from Niharika's Dockerized Bash App!"
echo "Build triggered by GitHub Actions CI Pipeline"
echo "Date: $(date)"
```

### 2. `Dockerfile` — Container Instructions
Tells Docker how to build the image:
```dockerfile
FROM bash:5.2
WORKDIR /app
COPY hello.sh .
RUN chmod +x hello.sh
CMD ["bash", "hello.sh"]
```
- `FROM bash:5.2` — uses the official bash image as the base
- `WORKDIR /app` — sets the working directory inside the container
- `COPY hello.sh .` — copies our script into the container
- `RUN chmod +x hello.sh` — makes the script executable
- `CMD` — runs the script when the container starts

### 3. `.github/workflows/docker-build-push.yml` — The CI Pipeline
```yaml
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
```

---

## Step-by-Step Process We Followed

### Step 1 — Set Up the Local Repository
```bash
# Initialized a fresh git repo inside the project folder
git init
git remote add origin https://github.com/niharikakanakala/Dummy.git
git checkout -b main
```

### Step 2 — Created the Application Files
- Created `hello.sh` (the dummy bash app)
- Created `Dockerfile` (to containerize the app)
- Created `.github/workflows/docker-build-push.yml` (the CI pipeline)

### Step 3 — Committed and Pushed to GitHub
```bash
git add .
git commit -m "Add Dockerfile, bash app, and GitHub Actions CI pipeline"
git push https://niharikakanakala:<PAT>@github.com/niharikakanakala/Dummy.git main
```

### Step 4 — Added GitHub Secrets
Added `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` as secrets in the GitHub repo settings so the pipeline can authenticate with Docker Hub securely.

### Step 5 — Fixed Docker Hub Token Permissions
The first pipeline runs failed with:
```
ERROR: unauthorized: access token has insufficient scopes
```
This happened because the Docker Hub token was created with Read-only access. We regenerated it with **Read, Write, Delete** permissions, updated the GitHub secret, and the pipeline succeeded.

---

## Complete End-to-End Flow

```
Developer writes/modifies code locally
              |
              v
git add . && git commit -m "message"
              |
              v
git push origin main
              |
              v
GitHub receives the push
              |
              v
GitHub Actions workflow triggers automatically
(.github/workflows/docker-build-push.yml)
              |
              v
GitHub spins up a fresh Ubuntu runner (virtual machine)
              |
              v
Step 1: Checkout — pulls the latest code onto the runner
              |
              v
Step 2: Login — authenticates with Docker Hub
         using DOCKERHUB_USERNAME and DOCKERHUB_TOKEN secrets
              |
              v
Step 3: Build — runs `docker build` using the Dockerfile
         packages hello.sh inside a bash:5.2 container
              |
              v
Step 4: Tag — applies two tags to the image:
         niharika13/niha_test:latest
         niharika13/niha_test:<git-commit-sha>
              |
              v
Step 5: Push — uploads both tagged images to Docker Hub
              |
              v
Image is live on Docker Hub
https://hub.docker.com/r/niharika13/niha_test
```

---

## Image Tagging Convention

| Tag | Example | Meaning |
|---|---|---|
| `latest` | `niharika13/niha_test:latest` | Always the most recent build — gets overwritten on every push |
| `<commit-sha>` | `niharika13/niha_test:abc1234...` | Unique tag per push — useful for rollback and traceability |

---

## What Happens When You Add a New File

Every push to `main` triggers the full pipeline automatically. If you add a new file on GitHub directly or push locally:
1. GitHub Actions detects the push
2. A new Docker image is built — including your new file
3. The `latest` tag on Docker Hub is updated
4. A new commit SHA tag is also created

You do not need to manually build or push anything.

---

## Useful Links

| Resource | URL |
|---|---|
| GitHub Repository | https://github.com/niharikakanakala/Dummy |
| GitHub Actions Runs | https://github.com/niharikakanakala/Dummy/actions |
| Docker Hub Repository | https://hub.docker.com/r/niharika13/niha_test |
| Docker Hub Tags | https://hub.docker.com/r/niharika13/niha_test/tags |
