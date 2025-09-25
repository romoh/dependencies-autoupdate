# Dependencies Autoupdate
A GitHub action that automates dependencies update. The action is designed to be language agnostic, It can run any dependency update commands and automatically creates a pull request if changes were detected. It can be used in conjunction with other steps to make updating dependencies easier.

dependencies-autoupdate can:
1. Run a dependencies update command ie: npm update, cargo update.. etc
2. Run a validation step to ensure the update command was successful ie: make, cargo test.. etc
3. Checks out a branch and creates a pull requests with the updated dependencies on success.

The action is language independent. Check the sample [go workflow](https://github.com/romoh/dependencies-autoupdate/blob/main/.github/workflows/autoupdate-dependencies-go.yml) & [rust workflow](https://github.com/romoh/dependencies-autoupdate/blob/main/.github/workflows/autoupdate-dependencies-rust.yml).

# Usage
### Example 1
```
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
      uses: romoh/dependencies-autoupdate@v1.1
      with: 
        token: ${{ secrets.GITHUB_TOKEN }}
        update-command: "go get -u && go mod tidy && go build"
        update-path: "'./test/go'" #optional
```

### Example 2, A schedule job to upgrade requirements via Make command
```bash
name: Auto update Python dependencies
on:
  schedule:
    # runs monthly At 00:01 on day-of-month 1
    - cron: '1 0 1 * *'
  workflow_dispatch:

jobs:
  auto-update:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout the head commit of the branch
      uses: actions/checkout@v4
      with:
        ref: staging

    - uses: actions/setup-python@v4
      with:
        python-version: '3.8'

    - name: Run auto dependency update
      uses: romoh/dependencies-autoupdate@v1.1
      with:
        token: ${{ secrets.GITHUB_TOKEN }}
        pr-branch: "staging"
        update-command: "make update"

```

Example 2 will create the PR against `staging` branch at the start of each month
It is recommended to use this action on a [schedule trigger](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions#onschedule) at a fixed cadence, but it can be used on other triggers as well. Just note GitHub has limitations on default GITHUB_TOKEN access from forks.

# Action inputs

Name |	Description	| Required | Default
--| --| --| --|
token |	GITHUB_TOKEN or a repo scoped Personal Access Token (PAT). | Yes | N/A
update-command | Command to update the dependencies and validate the changes. e.g. `cargo update && cargo test` or `go get -u && go mod tidy && go build`. | Yes | N/A
pr-branch | PR branch against which the PR should be created  | No | `main`
update-path | Path to execute the update command if different from the main working directory. | No | defaults to working directory
on-changes-command | Command to execute after updates to dependencies are detected. This will be executed before the pull request is created. e.g. version increment. | No | N/A

# Action outputs
- Success: Success means that the action completed successfully. If dependency updates were detected, a pull request will be open and action succeeds. Similarily, If no changes were detected, the action succeeds.
- Failure: Failure to run the update command will result in failing the action. This might indicate one or more dependencies do not strictly follow [SemVer conventions](https://semver.org/). In such cases, you might need to pin to specific versions in your dependency file (e.g. go.mod, Cargo.toml... etc.)

# Action behavior
The default behavior of the action is to create a pull request that will be continually updated with new changes until it is merged or closed. Changes are committed and pushed to a fixed-name branch. Any subsequent changes will be committed to the same branch and reflected in the open pull request.

If there are no changes (i.e. no diff exists with the checked-out base branch), no pull request will be created and the action exits silently.
If a pull request already exists and there are no further changes (i.e. no diff with the current pull request branch) then the action exits silently.

Notes:
* The committer name is set to the GitHub Actions bot user. GitHub <noreply@github.com>
* The pull request branch name is fixed and defaults to "automated-dependencies-update".
* Pull request defaults	to `main` branch when the value for `pr-branch` is not given 

# License
This tool is distributed under the terms of the MIT license. See [LICENSE](https://github.com/romoh/dependencies-autoupdate/blob/main/LICENSE) for details.
