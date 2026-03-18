# Day 22 – Understanding Git Workflow

## 1. Difference between git add and git commit

git add moves changes from the working directory into the staging area.

git commit creates a permanent snapshot of staged changes in the repository.

Working Directory → git add → Staging Area → git commit → Repository

---

## 2. What does the staging area do?

The staging area allows selective commits.

It helps:
- Organize commits logically
- Review changes before committing
- Maintain clean commit history

Git does not commit directly to allow control and structure.

---

## 3. What does git log show?

git log displays:
- Commit hash
- Author
- Date and time
- Commit message

It shows the full project history.

---

## 4. What is the .git folder?

The .git folder stores:
- Commit history
- Branch information
- Configuration
- Git objects database

If deleted, the project loses all version history.

---

## 5. Difference between working directory, staging area, and repository

Working Directory:
Where files are edited.

Staging Area:
Intermediate space where changes are prepared.

Repository:
Permanent stored history inside .git.
