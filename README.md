# redis

A multi-architecture Docker image for [Redis](https://redis.io/), built automatically via GitHub Actions and published to the GitHub Container Registry.

## Image URI

```
ghcr.io/cornyhorse/redis:<version>
```

**Examples:**
```
ghcr.io/cornyhorse/redis:7.4.2
ghcr.io/cornyhorse/redis:7.4
ghcr.io/cornyhorse/redis:7
```

## Supported Platforms

- `linux/amd64`
- `linux/arm64`

## How to Pull

```bash
docker pull ghcr.io/cornyhorse/redis:7.4.2
```

## How to Run

```bash
# Run with default settings
docker run -d -p 6379:6379 ghcr.io/cornyhorse/redis:7.4.2

# Run with a custom config file
docker run -d -p 6379:6379 \
  -v /path/to/redis.conf:/usr/local/etc/redis/redis.conf \
  ghcr.io/cornyhorse/redis:7.4.2 \
  redis-server /usr/local/etc/redis/redis.conf

# Run with persistent data
docker run -d -p 6379:6379 \
  -v redis-data:/data \
  ghcr.io/cornyhorse/redis:7.4.2
```

## How to Trigger a Build

Builds are triggered automatically in two ways:

### 1. Push a Git Tag

Create and push a version tag to trigger a build:

```bash
git tag 7.4.2
git push origin 7.4.2
```

The workflow will build and push the image with the following tags:
- `ghcr.io/cornyhorse/redis:7.4.2`
- `ghcr.io/cornyhorse/redis:7.4`
- `ghcr.io/cornyhorse/redis:7`

### 2. GitHub Release

Publish a new GitHub Release. The release tag is used as the image version.

### 3. Manual Workflow Dispatch

Trigger a build manually from the GitHub Actions UI:

1. Navigate to **Actions → Build and Push Multi-Arch Docker Image**
2. Click **Run workflow**
3. Enter the desired tag (e.g., `7.4.2`)

## Build Process

The CI/CD workflow (`.github/workflows/build-docker.yml`) performs the following steps:

1. **Checkout** — clones the repository
2. **QEMU** — sets up QEMU for cross-platform emulation (`linux/arm64`)
3. **Docker Buildx** — creates a multi-platform build environment
4. **Login** — authenticates to `ghcr.io` using `GITHUB_TOKEN`
5. **Metadata** — extracts version tags from the Git tag or release event
6. **Build & Push** — builds the multi-arch image and pushes to GHCR with layer caching

## Dockerfile

The `Dockerfile` uses a two-stage build:

- **Build stage** — downloads and compiles Redis from source (`debian:bookworm-slim`) with TLS and systemd support
- **Runtime stage** — copies only the compiled binaries into a fresh minimal image, runs as a non-root `redis` user

## Updating Redis Version

To build a newer Redis version, update the `ARG` values in the `Dockerfile`:

```dockerfile
ARG REDIS_VERSION=<new-version>
ARG REDIS_DOWNLOAD_SHA=<sha256-of-new-tarball>
```

Then push a new tag matching the Redis version.