#!/bin/bash

# Git Status Helper Script
# This script helps diagnose your Git situation and suggests actions

echo "🔍 Git Status Helper for Adrianne's Code Repository"
echo "=================================================="
echo

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: Not in a Git repository"
    exit 1
fi

echo "📊 Current Repository Status:"
echo "-----------------------------"

# Show current branch
current_branch=$(git branch --show-current)
echo "🌿 Current branch: $current_branch"

# Show remote info
echo "🌐 Remote repository: $(git remote get-url origin)"

# Check if there are any changes
if git diff-index --quiet HEAD --; then
    echo "✅ Working directory is clean (no uncommitted changes)"
    clean_working_dir=true
else
    echo "⚠️  Working directory has uncommitted changes"
    clean_working_dir=false
fi

echo
echo "📋 Detailed Status:"
echo "-------------------"
git status --porcelain | while read -r line; do
    status="${line:0:2}"  # Get first two characters
    file="${line:3}"      # Get filename (skip first 3 chars: status + space)
    
    case "$status" in
        "??") echo "  🆕 New file (untracked): $file" ;;
        " M") echo "  ✏️  Modified: $file" ;;
        " D") echo "  🗑️  Deleted: $file" ;;
        "A ") echo "  ➕ Added (staged): $file" ;;
        "M ") echo "  ✏️  Modified (staged): $file" ;;
        "D ") echo "  🗑️  Deleted (staged): $file" ;;
        "MM") echo "  ✏️  Modified (staged and unstaged): $file" ;;
        "AM") echo "  ➕ Added and modified: $file" ;;
        "AD") echo "  ➕ Added then deleted: $file" ;;
        *) echo "  ❓ Status '$status': $file" ;;
    esac
done

echo
echo "🎯 Recommended Actions:"
echo "-----------------------"

if $clean_working_dir; then
    echo "✅ Your working directory is clean. You can safely run:"
    echo "   git pull"
else
    echo "⚠️  You have uncommitted changes. Choose one option:"
    echo
    echo "Option 1 - Commit your changes (RECOMMENDED):"
    echo "   git add ."
    echo "   git commit -m \"Your commit message here\""
    echo "   git pull"
    echo
    echo "Option 2 - Stash your changes temporarily:"
    echo "   git stash -u"
    echo "   git pull"
    echo "   git stash pop"
    echo
    echo "Option 3 - Create a backup branch:"
    echo "   git checkout -b backup-$(date +%Y%m%d-%H%M%S)"
    echo "   git add ."
    echo "   git commit -m \"Backup of local changes\""
    echo "   git checkout $current_branch"
    echo "   git reset --hard HEAD"
    echo "   git pull"
fi

# Check if we can fetch to see if there are remote updates
echo
echo "🔄 Checking for remote updates..."
git fetch --dry-run origin 2>&1 | grep -q "up to date" 
if [ $? -eq 0 ]; then
    echo "✅ Your branch is up to date with remote"
else
    echo "📥 Remote updates are available"
    echo "   Run the recommended actions above, then 'git pull' to get updates"
fi

echo
echo "📚 For more detailed help, see: GIT_PULL_GUIDE.md"
echo "🆘 If you need help, run this script with your current status"