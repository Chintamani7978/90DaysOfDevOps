# Day 38 - YAML Basics

## Objective
Practice YAML syntax, structures, and validation.

## Files Created
- person.yaml
- server.yaml

## Task Notes
- Key-value pairs completed: Yes
- Lists completed (block and inline): Yes
- Nested objects completed: Yes
- Multi-line strings (| and >) completed: Yes

## Validation
- Validator used: yamllint (local) and yamllint.com (cross-check)
- Indentation error observed: Tab character and inconsistent indentation depth caused parser/lint failures.
- Fix applied: Replaced tabs with two spaces and aligned nested keys consistently.

## Spot the Difference
- Why block 2 is broken: The second list item is indented as if nested under the first item, creating invalid list structure. In YAML lists, peer items must align at the same indentation level under the parent key.

## Learnings
1. YAML is whitespace-sensitive, so indentation style must be consistent.
2. Lists can be written in block style using dash lines or inline style using brackets.
3. The pipe symbol preserves line breaks, while the greater-than symbol folds lines into a single wrapped string.
