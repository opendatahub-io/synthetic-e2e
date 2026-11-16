# Synthetic reference module

This repository contains the standalone, known-good module fixture used by the Open Data Hub platform E2E tests. It depends only on the public module framework and does not import Open Data Hub operator `internal` packages.

The healthy path demonstrates module conventions using `odh-platform-utilities/framework`:

- reconciler and action composition;
- dynamic ownership and server-side apply;
- standard finalizer handling;
- standard conditions and `observedGeneration`;
- the platform-version release handshake.

The controller owns a harmless ConfigMap named `synthetic-module-output` in `APPLICATIONS_NAMESPACE`. It reads the platform version from `odh-synthetice2e-config` in the same namespace and reports it through the `platform` release status entry.

## Deterministic fault injection

Tests can set the `test.synthetic.platform.opendatahub.io/fault` annotation on the singleton `SyntheticModule` to one of these values:

| Mode | Behavior |
| --- | --- |
| `ready-false` | Returns a provisioning error so the standard reconciler reports `Ready=False`. |
| `degraded` | Reports `Degraded=True`, which also makes the aggregated readiness unhealthy. |
| `stale-generation` | Completes reconciliation but reports `status.observedGeneration` one generation behind `metadata.generation`. |
| `stale-platform-release` | Reports the deliberately mismatched platform release `fault-injected-platform-release`. |
| `hold-finalizer` | While deletion is in progress, returns an actionable finalizer error and remains terminating until the annotation is removed. |

Removing the annotation restores normal behavior. An absent or unrecognized value is a no-op. These hooks are test-only and intentionally isolated from the healthy utilities-based render/load/deploy path; they are not a production module pattern.

## Build and test locally

```bash
make generate
make test
make build
make vet
make image IMG=quay.io/example/synthetic-module-operator:dev
```

`make generate` installs the pinned `controller-gen` version into `bin/` when needed. The Helm chart used to deploy the fixture is under `charts/synthetice2e`.
