# RiverLabs on AWS Lightsail

This setup builds the Vue 3 frontend and FastAPI backend into one Linux/AMD64
container. FastAPI serves the compiled site, client-side routes, and `/api/*`
endpoints. Lightsail provides the HTTPS public endpoint and checks
`/api/health`.

## Prerequisites

- AWS CLI v2 signed in to the AWS account and region where the service should
  live. The deploy script checks the active identity before making changes.
- Docker Desktop with Buildx and the Lightsail Control plugin (`lightsailctl`).
  On macOS, install the plugin with `brew install aws/tap/lightsailctl`.
- Permission to create and deploy Lightsail container services.

## Configure and deploy

```sh
cp cicd/lightsail.env.example cicd/lightsail.env
```

Review `LIGHTSAIL_REGION`, `LIGHTSAIL_SERVICE_NAME`, `LIGHTSAIL_POWER`, and
`LIGHTSAIL_SCALE` in the local settings file, then run:

```sh
./cicd/deploy-lightsail.sh
```

The first run creates a Lightsail Container Service if it does not already
exist, builds the app image, pushes it, and deploys it with the HTTPS endpoint.
Later runs publish a new image version to that same service. The default is a
single Nano node in `eu-north-1`; change the service power if the app's memory
or CPU metrics show it needs more capacity. Lightsail bills container services
while they are enabled or disabled, and deleting a service is required to stop
its service charges. See [AWS Lightsail container service pricing](https://aws.amazon.com/lightsail/pricing/)
before creating the resource.

The site and API share a single container, so no CORS configuration or second
public endpoint is needed. The deployed frontend uses the same origin for
`/api` requests. No database or persistent disk is configured in this starter;
add one deliberately before introducing state that must survive deployments.

## Local image check

```sh
./cicd/build-release.sh
docker run --rm -p 8000:8000 riverlabs-web:production
```

Then check `http://localhost:8000/`, `http://localhost:8000/products/river-flow`,
and `http://localhost:8000/api/health`.

## Operations

The Lightsail default domain is HTTPS. The service only exposes the application
container's HTTP port internally to the Lightsail HTTPS endpoint. Deployment
status and logs are available in the Lightsail console. Older deployments are
kept for rollback according to Lightsail's deployment history. To stop billing,
delete the service after confirming you no longer need it.
