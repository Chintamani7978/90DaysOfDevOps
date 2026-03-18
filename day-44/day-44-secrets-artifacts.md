# Day 44 - Secrets, Artifacts, and Real Tests in CI

## Objective
Use secrets safely, pass artifacts, run real tests, and cache dependencies.

## Task 1 - GitHub Secrets
- Secret created: MY_SECRET_MESSAGE
- Secret presence check output: Logged a boolean-style message only (The secret is set: true).
- Masking behavior observed: GitHub masked secret values in logs when direct echo was attempted.
- Why not print secrets: Logs can be exposed to collaborators and retained; leaking secrets can compromise infrastructure and accounts.

## Task 2 - Secrets as Environment Variables
- Secret passed via env: Yes
- DOCKER_USERNAME set: Yes
- DOCKER_TOKEN set: Yes

## Task 3 - Upload Artifacts
- Artifact generated: test-report.txt / build-log.txt
- Artifact upload step: actions/upload-artifact@v4
- Download from Actions tab verified: Yes

## Task 4 - Download Artifacts Between Jobs
- Producer job: generate-report
- Consumer job: consume-report
- Artifact usage confirmed: Yes (downloaded and printed contents).

## Task 5 - Run Real Tests
- Script used: Existing shell or Python script from earlier day practice.
- Dependencies installed: Runtime and package dependencies installed in workflow.
- Red run observed after intentional break: Yes
- Green run observed after fix: Yes

## Task 6 - Caching
- Cache key strategy: OS plus lockfile hash (for example, runner.os-deps-hashFiles('**/requirements.txt')).
- First run vs second run time notes: First run populated cache; second run was faster due to cache hit.
- What is cached and where: Dependency directories are cached in GitHub's artifact/cache backend and restored to runners on matching keys.

## Evidence
- Screenshot links/paths: To be added (artifact upload/download and passing test run).
