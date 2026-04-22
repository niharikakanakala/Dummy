# CI Pipeline — GitHub Actions + Docker Hub

## What We Built

A Continuous Integration (CI) pipeline that automatically builds a Docker image and pushes it to Docker Hub every time code is pushed to the `main` branch on GitHub.

---

## Files in This Repository

| File | Purpose |
|---|---|
| `hello.sh` | A simple bash script — the application being containerized |
| `Dockerfile` | Instructions to build the Docker image from `hello.sh` |
| `.github/workflows/docker-build-push.yml` | GitHub Actions workflow — defines the CI pipeline |

---

## Credentials Required

### 1. GitHub Personal Access Token (PAT)
- Used to push code from your local machine to GitHub via terminal
- Generate at: GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
- Required scope: `repo` (full control)
- Used as password when running `git push`

### 2. Docker Hub Access Token
- Used by GitHub Actions to authenticate and push images to Docker Hub
- Generate at: Docker Hub → Account Settings → Personal access tokens → Generate new token
- Required permissions: **Read, Write, Delete**
- Stored as a GitHub Secret (never in code)

### 3. GitHub Secrets (set in the repository)
- Go to: GitHub repo → Settings → Secrets and variables → Actions
- Two secrets must be added:

| Secret Name | Value |
|---|---|
| `DOCKERHUB_USERNAME` | Your Docker Hub username |
| `DOCKERHUB_TOKEN` | Your Docker Hub Access Token (Read, Write, Delete) |

---

## Flow — How It All Works

```
Developer pushes code to GitHub (main branch)
                |
                v
    GitHub Actions workflow triggers
    (.github/workflows/docker-build-push.yml)
                |
                v
    Runner checks out the repository code
                |
                v
    Logs in to Docker Hub
    (using DOCKERHUB_USERNAME and DOCKERHUB_TOKEN secrets)
                |
                v
    Builds Docker image from Dockerfile
                |
                v
    Tags the image:
      - niharika13/niha_test:latest
      - niharika13/niha_test:<commit-sha>
                |
                v
    Pushes both tags to Docker Hub
                |
                v
    Image is available at:
    https://hub.docker.com/r/niharika13/niha_test
```

---

## Image Tagging Convention

| Tag | Meaning |
|---|---|
| `latest` | Always points to the most recent successful build |
| `<commit-sha>` | Unique tag tied to the exact Git commit — useful for traceability |

---

## How to Trigger the Pipeline

Any push to the `main` branch triggers the pipeline automatically:

```bash
git add .
git commit -m "your message"
git push origin main
```

No manual steps needed — GitHub Actions handles the rest.

---

## Verify on Docker Hub

After a successful pipeline run, check:
- Tags: https://hub.docker.com/r/niharika13/niha_test/tags
- Actions: https://github.com/niharikakanakala/Dummy/actions
