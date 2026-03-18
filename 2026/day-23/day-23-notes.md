# Day 23 – Git Branching & Working with GitHub

Overview

Today I focused on understanding Git branching and working with GitHub remotes.
Branching is one of the most powerful features in Git, allowing safe and structured development without affecting stable code.

This exercise included hands-on practice with branch creation, switching, deleting, pushing to GitHub, pulling changes, and understanding clone vs fork.

Task 1 – Understanding Branches
# 1. What is a branch in Git?

A branch in Git is a movable pointer to a commit.
It allows independent development within the same repository.

Each branch can have its own commit history without interfering with others.

# 2. Why do we use branches instead of committing everything to main?

Branches allow:

Safe feature development

Bug fixes without breaking stable code

Experimentation

Cleaner and more organized version history

The main branch should remain stable and production-ready.

# 3. What is HEAD in Git?

HEAD is a pointer to the current active branch and its latest commit.

When switching branches, HEAD moves accordingly.

# 4. What happens when switching branches?

When switching branches:

Git updates the working directory to match the selected branch.

Files may change based on commits in that branch.

Uncommitted changes may block switching.

# Task 2 – Branching Commands — Hands-On
![alt text](image.png)
![alt text](image-1.png)

```bash
git branch
git branch feature-1
git switch feature-1
git switch -c feature-2
git checkout main
git branch -d feature-2
git log --oneline --graph --all


```

# Task 3 – Working with GitHub
Connecting Local Repo to GitHub
```bash
git remote add origin git@github.com:Chintamani7978/devops-git-practice.git
git push -u origin main
git push -u origin feature-1
```

Both branches were successfully pushed and verified on GitHub.
![alt text](image-3.png)
![alt text](image-2.png)


# Task 4 – Pull vs Fetch
```bash
git fetch
```
Downloads changes from the remote repository but does NOT merge them automatically.
```bash
git pull
git pull
```
Downloads changes AND merges them into the current branch.
```bash
git pull = git fetch + git merge
```
Task 5 – Clone vs Fork
Clone

A Git command that copies a remote repository to a local machine.

Example:
```bash
git clone <repository-url>

```
Used when I just need a local copy.

Fork

A GitHub feature that creates a copy of someone else's repository under my GitHub account.

Used when I want to contribute to a project without affecting the original repository.

Keeping a Fork Updated
```bash
git remote add upstream <original-repo-url>
git fetch upstream
git merge upstream/main

```
This keeps my fork synchronized with the original repository.

Commands Added to git-commands.md
```bash
git branch

git switch

git switch -c

git checkout

git branch -d

git remote add

git push

git pull

git fetch

git clone
```

![alt text](image-4.png)