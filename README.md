# dependencies-autoupdate
A GitHub action that automates dependencies update. The action is designed to be language agnostic, It can run any dependency update commands and automatically creates a pull request if changes were detected. It can be used in conjunction with other steps to make updating dependencies easier.

dependencies-autoupdate can:
1. Run a dependencies update command ie: npm update, cargo update.. etc
2. Run a validation step to ensure the update command was successful ie: make, cargo test.. etc
2. Checks out a branch and creates a pull requests with the updated dependencies on success.

Note: This action was tested with cargo. Further contributions are welcomed.

# Usage
'
jobs:
  auto-update:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout the head commit of the branch
      uses: actions/checkout@v2
      with:
        persist-credentials: false
        
    - name: Install re[po specific requirements
      run: |
        apt_dependencies="git curl libssl-dev pkg-config libudev-dev libv4l-dev"
        echo "Run apt update and apt install the following dependencies: $apt_dependencies"
        sudo apt update
        sudo apt install -y $apt_dependencies
    
    - name: Run auto dependency update 
      uses: ./.github/actions/auto-update-dependencies
      with: 
        token: ${{ secrets.GITHUB_TOKEN }}
        repo: "akri"
        update-command: "'cargo update && cargo test'" 
        '

# Action inputs
All inputs are optional. If not set, sensible defaults will be used.

Note: If you want pull requests created by this action to trigger an on: push or on: pull_request workflow then you cannot use the default GITHUB_TOKEN. See the documentation here for workarounds.

Name |	Description	| Default
--| --| --|
token |	GITHUB_TOKEN or a repo scoped Personal Access Token (PAT). | GITHUB_TOKEN
repo	| The name of the repo.	N/A
update-command | The command to update the dependencies and validation commands for validating successful update. N/A

# Action outputs
- Success: success means that the action completed successfully. If no dependencies updates were observed, the action is completed. If changes were detected, a pull request will be open.
- Failure: In case of any intermident failure steps, the action will fail.

# Action behavior
    - The committer name defaults to the GitHub Actions bot user. GitHub <noreply@github.com>
    - The pull request branch name is fixed and defaults to "autoupdate-dependencies"
    - Pull request defaults	to the branch checked out in the workflow.

The default behavior of the action is to create a pull request that will be continually updated with new changes until it is merged or closed. Changes are committed and pushed to a fixed-name branch. Any subsequent changes will be committed to the same branch and reflected in the open pull request.

How the action behaves:
If there are no changes (i.e. no diff exists with the checked-out base branch), no pull request will be created and the action exits silently.
If a pull request already exists and there are no further changes (i.e. no diff with the current pull request branch) then the action exits silently.


Future: 
* Keep the branch up to do in case of non-merged previous code reviews with dependencies update.
