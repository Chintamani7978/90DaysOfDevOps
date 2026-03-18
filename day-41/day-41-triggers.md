# Day 41 - Triggers and Matrix Builds

## Objective
Practice workflow triggers and matrix strategy.

## Task 1 - Pull Request Trigger
- Workflow file: .github/workflows/pr-check.yml
- Trigger config: pull_request on main branch for opened and synchronize events.
- PR run verified: Yes

## Task 2 - Scheduled Trigger
- Cron used for daily midnight UTC: 0 0 * * *
- Cron for Monday 9 AM: 0 9 * * 1

## Task 3 - Manual Trigger
- workflow_dispatch file: .github/workflows/manual.yml
- Input used: environment (staging or production)
- Manual run result: Triggered from Actions tab and input value printed successfully.

## Task 4 - Matrix Builds
- Python versions tested: 3.10, 3.11, 3.12
- OS matrix added: Yes (ubuntu-latest and windows-latest)
- Total jobs generated: 6 (3 versions x 2 OS values)

## Task 5 - Exclude and Fail-Fast
- Excluded combination: windows-latest with python 3.10
- fail-fast value used: false
- Observed behavior: Other matrix jobs continued and completed even when one job failed.

## Evidence
- Screenshots or run links: To be added from GitHub Actions runs.

## Learnings
1. Different trigger types are useful for different lifecycle events, not just push.
2. Matrix strategy provides scalable cross-version and cross-platform validation.
3. fail-fast false improves visibility of all failing combinations in a single run.
