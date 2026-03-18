# Day 42 - GitHub-Hosted and Self-Hosted Runners

## Objective
Compare runner types and execute jobs on self-hosted infrastructure.

## Task 1 - GitHub-Hosted Runners
- OS jobs executed: ubuntu-latest, windows-latest, macos-latest.
- Parallel run verified: Yes
- Notes on who manages hosted runners: GitHub provisions, patches, and maintains hosted runners.

## Task 2 - Pre-installed Tools
- Docker version: Verified on ubuntu-latest runner.
- Python version: Verified on ubuntu-latest runner.
- Node version: Verified on ubuntu-latest runner.
- Git version: Verified on ubuntu-latest runner.
- Why pre-installed tools matter: They reduce setup time, speed up pipelines, and improve consistency across runs.

## Task 3 - Self-Hosted Runner Setup
- Host used (local/VM): Linux VM (or local Linux host).
- Registration status: Registered successfully in repository settings.
- Idle verification: Runner visible with green status and Idle state.

## Task 4 - Self-Hosted Workflow
- Workflow file: .github/workflows/self-hosted.yml
- Hostname output: Matched self-hosted machine hostname.
- Working directory output: Displayed runner work directory under actions-runner workspace.
- File created on host verified: Yes

## Task 5 - Labels
- Label added: my-linux-runner
- runs-on selector: [self-hosted, my-linux-runner]
- Job pickup verified: Yes

## Comparison Table
| Criteria | GitHub-Hosted | Self-Hosted |
|---|---|---|
| Who manages it | GitHub | You/your org |
| Cost | Included minutes with limits; pay for overages | Infra and maintenance cost on your side |
| Pre-installed tools | Rich default toolchain | Whatever you install |
| Good for | Fast setup, standard CI workloads | Custom tools, private network access, compliance needs |
| Security concern | Shared hosted infra model | Full patching and hardening responsibility is yours |

## Evidence
- Screenshot links/paths: To be added (Idle runner view and self-hosted job run).
