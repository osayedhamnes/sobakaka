#!/bin/bash

# Exit if any command fails
set -e

# Check if we're inside a CircleCI job (optional, for debugging)
if [ -z "$CIRCLECI" ]; then
  echo "This script must run within CircleCI"
  exit 1
fi

# Verify that the repository is already cloned (CircleCI does this for you)
if [ ! -d ".git" ]; then
  echo "Repository is not cloned. This should never happen in CircleCI."
  exit 1
fi

# Ensure we're on the latest commit from the default branch (CircleCI default branch is set to `$CIRCLE_BRANCH` by default)
git checkout "$CIRCLE_BRANCH"  # Checkout the branch CircleCI is working with

# Optionally, checkout a specific commit or tag (you can adjust this part)
# git checkout <commit-hash>   # Replace with specific commit hash
# git checkout <tag-name>      # Replace with a specific tag

# Example: Checkout to the `main` branch (or any other branch/tag)
git checkout main  # Checkout to the 'main' branch or any other branch you need

# If you need to pull the latest changes (optional)
git pull origin "$CIRCLE_BRANCH"  # Pull the latest changes from the branch
