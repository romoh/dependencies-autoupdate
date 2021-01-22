#!/bin/bash

TOKEN=$1
REPO=$2
UPDATE_COMMAND=$3
PATH='./test/rust'
USERNAME=$4
ORGANIZATION=$5

BRANCH_NAME="automated-dependencies-update"
EMAIL="noreply@github.com"

if [ -z "$TOKEN" ]; then
    echo "Token is not defined"
    exit 1
fi

if [ -z "$ORGANIZATION" ]; then
    echo "Organization is not defined, defaulting to $USERNAME"
    ORGANIZATION=USERNAME
fi

# if [ -n "$PATH" ]; then
#      cd './test/rust' #TODO: Use from parameter
# fi

#echo "Switched to $PATH"
cd './test/rust'

# assumes the repo is already cloned as a prerequisite for running the script

# check if branch already exists
if [ "git branch --list $BRANCH_NAME" ]
then
    echo "Branch name $BRANCH_NAME already exists"

    echo "Check out branch instead" 
    # check out existing branch
    git checkout $BRANCH_NAME

    # reset with latest from main
    git reset --hard origin/main
else
    git checkout -b $BRANCH_NAME
fi

echo "Running update command $UPDATE_COMMAND"
eval $UPDATE_COMMAND

if [ -n "git diff" ]
then
    echo "Updates detected"

    # configure git authorship
    git config --global user.email $EMAIL
    git config --global user.name $USERNAME

    # format: https://[USERNAME]:[TOKEN]@github.com/[ORGANIZATION]/[REPO].git
    git remote add authenticated "https://$USERNAME:$TOKEN@github.com/$ORGANIZATION/$REPO.git"

    # commit the changes to Cargo.lock
    git commit -a -m "Auto-update cargo crates"
    
    # push the changes
    git push authenticated $BRANCH_NAME

    echo "https://api.github.com/repos/$ORGANIZATION/$REPO/pulls"

    # create the PR
    # if PR already exists, then update
    HTTP_CODE=$(curl --write-out "%{http_code}\n" -X POST -H "Content-Type: application/json" -H "Authorization: token $TOKEN" \
         --data '{"title":"Autoupdate dependencies","head": "'"$BRANCH_NAME"'","base":"main", "body":"Auto-generated pull request. \nThis pull request is generated by GitHub action based on the provided update commands."}' \
         "https://api.github.com/repos/$ORGANIZATION/$REPO/pulls")
    
    echo HTTP_CODE         
fi
