# Git Commands Reference

This document contains Git commands I am learning during my DevOps journey.

---

## Setup & Configuration

### git --version
Checks installed Git version.
Example:
git --version

### git config --global user.name
Sets global username for commits.
Example:
git config --global user.name "Your Name"

### git config --global user.email
Sets global email for commits.
Example:
git config --global user.email "your-email@example.com"

---
![alt text](<Screenshot 2026-02-18 233511.png>)

## Repository Initialization

### git init
Initializes a new Git repository.
Example:
git init

---

## Basic Workflow

### git status
Shows current state of working directory and staging area.
Example:
git status

### git add
Stages changes to be committed.
Example:
git add filename

### git commit
Creates a snapshot of staged changes.
Example:
git commit -m "meaningful message"

---
![alt text](<Screenshot 2026-02-18 233655.png>)

## Viewing Changes & History

### git diff
Shows changes between working directory and staging area.
Example:
git diff

### git log
Shows detailed commit history.
Example:
git log

### git log --oneline
Shows compact commit history.
Example:
git log --oneline

---
![alt text](<Screenshot 2026-02-18 234347.png>)
## Branch Information

### git branch
Lists available branches.
Example:
git branch

![alt text](<Screenshot 2026-02-18 234607.png>)