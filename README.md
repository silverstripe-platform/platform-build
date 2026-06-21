# Platform Build

Transforms a Silverstripe CMS project into a deployable bundle using Composer
and related tools. This is primarily designed for use during deployments to
[Silverstripe Cloud](https://silverstripe.cloud).

## What is this?

This is a Docker container that runs three primary commands:

 - composer validate
 - composer install --no-progress --prefer-dist --no-dev --ignore-platform-reqs --optimize-autoloader --no-interaction --no-suggest
 - composer vendor-expose copy

If present in the codebase, and CLOUD_BUILD_DISABLED env variable is not set, it will also run the following scripts:

 - npm/yarn run cloud-build (after running npm/yarn install)
 - composer run-script cloud-build

## Example usage / local debugging

You can run the container against a project locally to test or diagnose issues:

```
docker run \
    --interactive \
    --tty \
    --volume composer_cache:/tmp/cache \
    --volume ~/.ssh/id_rsa:/root/.ssh/id_rsa:ro \
    --volume $PWD:/app \
    ghcr.io/silverstripe/platform-build
```

`--volume composer_cache:/tmp/cache`

Creates a composer_cache volume if it doesn't exists and mounts that into the
Composer home folder `tmp`

`--volume ~/.ssh/id_rsa:/root/.ssh/id_rsa`

If your source code has private repositories, you will need to mount your
private key (deploy key) into the container (preferable as read only)

`--volume $PWD:/app`

The source code will be built from the `/app` directory inside the container, so
make sure you mount your source code into that.

## Building and Publishing

Images are published to GitHub Container Registry at `ghcr.io/silverstripe-platform/platform-build`.

### Prerequisites

Set environment variables for authentication:

```bash
export GHCR_USER=<your-github-username>
export GHCR_TOKEN=<your-github-personal-access-token>
```

The token needs the `write:packages` scope.

See [https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-with-a-personal-access-token-classic](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-with-a-personal-access-token-classic) for creating tokens.

### Login

```bash
make login
```

### Build a versioned image

```bash
make build VERSION=1.2.3
```

This tags both `ghcr.io/silverstripe-platform/platform-build:1.2.3` and `:latest`.

### Push to GHCR

```bash
make push VERSION=1.2.3
```

### Full release (login, build, push)

```bash
make release VERSION=1.2.3
```

## Maintenance

See [maintenance](docs/maintenance.md).
