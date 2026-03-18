# Day 40 - First GitHub Actions Workflow

## Objective
Create and understand a first workflow run.

## Workflow File
- .github/workflows/hello.yml

## What Was Implemented
- Trigger on push: Yes
- Job name greet: Yes
- runs-on ubuntu-latest: Yes
- Checkout step: Yes
- Hello message step: Yes

## Extra Steps Added
- Current date/time
- Branch name
- File list
- Runner OS

## Break and Fix Exercise
- Failure introduced: Added a failing command (exit 1) to one step.
- Error observed: Workflow run turned red; job stopped at the failing step and logs showed non-zero exit code.
- Fix applied: Removed failing command and reran workflow to confirm green status.

## Key Anatomy Notes
- on: Defines which events trigger the workflow.
- jobs: Top-level section containing one or more jobs.
- runs-on: Specifies runner OS/environment for a job.
- steps: Ordered list of actions or commands inside a job.
- uses: Executes a reusable action (for example, actions/checkout).
- run: Executes shell commands directly on the runner.
- name: Human-readable label for workflows, jobs, or steps in the Actions UI.

## Evidence
- Screenshot path/link: To be added after final run screenshots are captured.
