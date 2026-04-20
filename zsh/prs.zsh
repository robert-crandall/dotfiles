#!/bin/zsh

# Function to set the default branch
function set_git_branch() {
  local branch=$1
  if [[ -z $branch ]]; then
    echo "Usage: set_git_branch <branch>"
    return 1
  fi

  # Check if the branch exists
  if ! git show-ref --verify --quiet refs/heads/$branch; then
    echo "Branch '$branch' does not exist."
    return 1
  fi

  export GIT_BRANCH=$branch
  echo "Default branch set to '$GIT_BRANCH'"
}

# Function to copy a file from a branch to the current branch
function cpg() {
  local filename=$1

  if [[ -z $GIT_BRANCH || -z $filename ]]; then
    echo "Usage: cpg [branch] <filename>"
    echo " - Use set_git_branch to set default branch, or EXPORT GIT_BRANCH=<branch>."
    return 1
  fi

  # Check if the branch exists
  if ! git show-ref --verify --quiet refs/heads/$GIT_BRANCH; then
    echo "Branch '$GIT_BRANCH' does not exist."
    return 1
  fi

  # Check out the file from the specified branch
  git checkout $GIT_BRANCH -- $filename

  if [[ $? -eq 0 ]]; then
    echo "Successfully copied '$filename' from branch '$GIT_BRANCH' to the current branch."
  else
    echo "Failed to copy '$filename' from branch '$GIT_BRANCH'."
    return 1
  fi
}
