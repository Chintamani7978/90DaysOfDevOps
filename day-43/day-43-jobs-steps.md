# Day 43 - Jobs, Steps, Env Vars, and Conditionals

## Objective
Control workflow execution flow and data passing.

## Task 1 - Multi-Job Workflow
- Jobs created: build, test, deploy
- Dependency chain verified: Yes (test depends on build, deploy depends on test)

## Task 2 - Environment Variables
- Workflow-level var: APP_NAME=myapp
- Job-level var: ENVIRONMENT=staging
- Step-level var: VERSION=1.0.0
- GitHub context printed (sha/actor): Yes

## Task 3 - Job Outputs
- Output producer job: build-meta
- Output consumer job: summary
- Value passed: build_date or build_version via GITHUB_OUTPUT and needs.<job>.outputs.<name>
- Why outputs are useful: They allow safe and explicit data sharing across jobs without recomputation.

## Task 4 - Conditionals
- Main branch-only step: Used if expression on refs/heads/main.
- Run on previous failure step: Used if: failure() for diagnostics.
- Push-only job: Added if: github.event_name == 'push'.
- continue-on-error observation: Step failure is recorded but does not fail the full job immediately.

## Task 5 - Smart Pipeline
- Trigger: push on any branch.
- Parallel jobs: lint and test run concurrently.
- Summary job behavior: Runs after both jobs and prints main vs feature branch context.
- Commit message printed: Yes

## Learnings
1. needs creates deterministic job order and a clear workflow graph.
2. Scoped environment variables keep pipelines cleaner and more maintainable.
3. Conditionals are essential for branch-specific logic and controlled failure handling.
