# Git Pull Guide: Handling Local Changes

## Overview
When you've added and deleted files locally in your repository and need to pull updates from the remote repository, you need to handle your local changes properly to avoid conflicts and data loss.

## Quick Reference Commands

### 1. Check Your Current Status
```bash
git status
```
This shows you what files have been:
- Added (new files)
- Modified (existing files changed)
- Deleted (files removed)
- Untracked (new files not yet added to git)

### 2. Before Pulling - Save Your Work

#### Option A: Commit Your Changes (Recommended)
```bash
# Add all changes
git add .

# Commit with a descriptive message
git commit -m "Add/delete files: [brief description of changes]"

# Now pull safely
git pull
```

#### Option B: Stash Your Changes (Temporary Storage)
```bash
# Stash changes including untracked files
git stash -u

# Pull updates
git pull

# Restore your changes
git stash pop
```

#### Option C: Create a Backup Branch
```bash
# Create and switch to backup branch
git checkout -b backup-my-changes

# Commit everything
git add .
git commit -m "Backup of local changes"

# Switch back to main branch
git checkout main

# Reset to clean state and pull
git reset --hard HEAD
git pull
```

## Detailed Scenarios

### Scenario 1: You've Added New Files
If you've created new files that don't exist in the remote repository:

```bash
# See what's new
git status

# Add the new files
git add [filename] # or git add . for all files

# Commit them
git commit -m "Add new files: [list the important ones]"

# Pull updates
git pull
```

### Scenario 2: You've Deleted Files
If you've removed files that might still exist in the remote repository:

```bash
# See what's been deleted
git status

# If you want to keep the deletions:
git add . # This stages the deletions
git commit -m "Remove unnecessary files"
git pull

# If you want to restore deleted files instead:
git checkout HEAD -- [filename] # Restore specific file
# or
git reset --hard HEAD # Restore all deleted files
git pull
```

### Scenario 3: Mixed Changes (Added + Deleted + Modified)
For complex changes involving multiple types of modifications:

```bash
# Review all changes
git status
git diff # See what changed in existing files

# Stage changes selectively if needed
git add [specific-files] # Add only files you want to keep
# or
git add . # Add everything

# Commit your changes
git commit -m "Update project: add new analysis files, remove obsolete code"

# Pull updates
git pull
```

## Handling Conflicts After Pull

If `git pull` results in merge conflicts:

```bash
# See conflicted files
git status

# Edit conflicted files to resolve conflicts
# Look for conflict markers: <<<<<<<, =======, >>>>>>>

# After resolving conflicts, add the files
git add [resolved-files]

# Complete the merge
git commit -m "Resolve merge conflicts"
```

## Best Practices

1. **Always check status first**: `git status` before any operation
2. **Commit frequently**: Don't let changes accumulate too long
3. **Use descriptive commit messages**: Explain what you added/removed and why
4. **Pull regularly**: Stay up to date with remote changes
5. **Test after pulling**: Make sure everything still works

## Emergency Recovery

If something goes wrong:

```bash
# See recent commits
git log --oneline -10

# Go back to a previous commit (replace COMMIT_HASH)
git reset --hard COMMIT_HASH

# Or undo the last commit (keeping changes)
git reset --soft HEAD~1

# Force pull (WARNING: loses local changes)
git fetch origin
git reset --hard origin/main
```

## Repository-Specific Notes

For this Adrianne Salk project repository:
- Main files include R Markdown documents (.Rmd) and their HTML outputs
- HTML files are generated from .Rmd files, so focus on committing .Rmd changes
- The repository includes data analysis code for CO2 measurements and FTIR spectroscopy
- Consider adding a .gitignore file to exclude temporary files and large data files

## Example Workflow for This Repository

```bash
# 1. Check what you've changed
git status

# 2. Add your analysis files (focus on .Rmd files)
git add *.Rmd
git add index.html  # if you modified the main page

# 3. Commit with context
git commit -m "Update analysis: add new FTIR processing code and CO2 plotting"

# 4. Pull latest changes
git pull

# 5. If there are conflicts in HTML files, regenerate them
# (since HTML files are generated from .Rmd, you can regenerate them)
```

## Getting Help

If you're stuck:
1. `git status` - see current state
2. `git log --oneline -5` - see recent changes
3. `git diff` - see what changed
4. `git stash` - temporarily save changes if needed
5. Ask for help with the specific error message you're seeing