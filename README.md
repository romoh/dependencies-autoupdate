# dependencies-autoupdate
A GitHub action that automates dependencies update. The action is designed to be language agnostic, It can run any dependency update commands and automatically creates a pull request if changes were detected. It can be used in conjunction with other steps to make updating dependencies easier.

dependencies-autoupdate can:
1. Run a dependencies update command ie: npm update, cargo update.. etc
2. Run a validation step to ensure the update command was successful ie: make, cargo test.. etc
2. Checks out a branch and creates a pull requests with the updated dependencies on success.

The action is language independant. Check the sample [go workflow](https://github.com/romoh/dependencies-autoupdate/blob/main/.github/workflows/autoupdate-dependencies-go.yml) & [rust workflow](https://github.com/romoh/dependencies-autoupdate/blob/main/.github/workflows/autoupdate-dependencies-rust.yml).

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
                  
    - name: Go setup
      uses: actions/setup-go@v2
             
    - name: Run auto dependency update 
      uses: romoh/dependencies-autoupdate@main
      with: 
        token: ${{ secrets.GITHUB_TOKEN }}
        update-command: "'go get -u && go mod tidy && go build'"
        update-path: "'./test/go'"
        '
It is recommended to use this action on a [schedule trigger](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions#onschedule) at fixed cadence, but it can be used on other triggers as well. Just note GitHub has limitation on default GITHUB_TOKEN access from fork repos.

# Action inputs

Name |	Description	| Required | Default
--| --| --| --|
token |	GITHUB_TOKEN or a repo scoped Personal Access Token (PAT). | Yes | N/A
update-command | The command to update the dependencies and validation commands for validating successful update. ie: 'cargo update && cargo test' or 'go get -u && go mod tidy && go build' | Yes | N/A
update-path | Path to execute the update command in case the required dependencies update don't exist at the main working directory | No | defaults to working directory

# Action outputs
- Success: success means that the action completed successfully. If dependency updates were detected, a pull request will be open and action succeeds. Similarily, If no changes were detected, the action succeeds.
- Failure: In case of any unexpected intermident failure steps, the action will fail. This is not expected to happen. Please report it as a bug.

# Action behavior
The default behavior of the action is to create a pull request that will be continually updated with new changes until it is merged or closed. Changes are committed and pushed to a fixed-name branch. Any subsequent changes will be committed to the same branch and reflected in the open pull request.

If there are no changes (i.e. no diff exists with the checked-out base branch), no pull request will be created and the action exits silently.
If a pull request already exists and there are no further changes (i.e. no diff with the current pull request branch) then the action exits silently.

Notes:
* The committer name is set to the GitHub Actions bot user. GitHub <noreply@github.com>
* The pull request branch name is fixed and defaults to "automated-dependencies-update".
* Pull request defaults	to the branch checked out in the workflow.

License
This tool is distributed under the terms of the MIT license. See [LICENSE](https://github.com/romoh/dependencies-autoupdate/blob/main/LICENSE) for details.
