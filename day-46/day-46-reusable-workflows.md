# Day 46 - Reusable Workflows and Composite Actions

## Objective
Create reusable CI building blocks with workflow_call and composite actions.

## Task 1 - Concepts
- Reusable workflow: A workflow designed to be called by other workflows to avoid duplicating CI logic.
- workflow_call: A trigger that enables one workflow to be invoked by another workflow.
- Reusable workflow vs regular action: Reusable workflows operate at job/workflow level; actions are typically invoked inside steps.
- Required file location: .github/workflows/

## Task 2 - Reusable Workflow
- File: .github/workflows/reusable-build.yml
- Inputs configured: app_name (required string), environment (required string with default staging behavior in usage pattern).
- Secrets configured: docker_token (required).
- Build print step verified: Yes

## Task 3 - Caller Workflow
- File: .github/workflows/call-build.yml
- Trigger: push to main.
- uses syntax validated: Yes (uses: ./.github/workflows/reusable-build.yml)
- Inputs printed in run logs: Yes

## Task 4 - Outputs
- build_version output configured: Yes
- Consumer job reads output: Yes
- Printed output value: v1.0-<short-sha>

## Task 5 - Composite Action
- Action file: .github/actions/setup-and-greet/action.yml
- Inputs: name and language (default en).
- Output greeted=true set: Yes
- Workflow invocation result: Composite action executed successfully and printed greeting plus runner details.

## Task 6 - Comparison Table
| Criteria | Reusable Workflow | Composite Action |
|---|---|---|
| Triggered by | workflow_call | uses in a step |
| Can contain jobs | Yes | No |
| Can contain multiple steps | Yes (inside jobs) | Yes |
| Lives where | .github/workflows | Any action directory containing action.yml (for example .github/actions/...) |
| Can accept secrets directly | Yes, via workflow_call secrets | Not directly as a first-class secrets section; pass via env/inputs |
| Best for | Standardizing multi-job CI/CD patterns across repos | Reusing step sequences in one or many workflows |

## Evidence
- Screenshot links/paths: To be added (caller workflow and composite action runs).
