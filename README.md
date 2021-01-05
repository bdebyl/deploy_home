# Deploy Home
There's no place like home!


Just as Dorothy managed the simple task of clicking her heels together, the
desire for an equally simple one-button push deployment was in my heart. Thus,
this repository was made.

[![Build Status](https://ci.bdebyl.net/api/badges/bdebyl/deploy_home/status.svg)](https://ci.bdebyl.net/bdebyl/deploy_home)

## Ansible
Ansible, along with double encrypted secrets, deploys the necessary
configurations to make the home fit for certain needs and desires. Namely,
having access to my home from anywhere, securely, and a self-hosted CI server
that easily ties into existing workflows.


## Makefile
The makefile is primarily used as a wrapper script to ensure that necessary
files, such as the secret vault password file, are provisioned as part of this.
One such addition to the task is utilizing dependency pinning through the
utilization of Python's `virtualenv` to lock down the specific dependency
versions within the `requirements.txt` file. This, ideally, prevents any
deployment issues with dependency version woes (_e.g. version conflicts, major
updates in newest versions, etc._)


| Target Name | Description                                                                          |
|-------------|--------------------------------------------------------------------------------------|
| `lint`      | (default) Runs `yamllint` and `ansible-lint` on *all* YAML files in `ansible/`       |
| `deploy`    | Deploys everything, or only tasks specified in `TAGS=` environment variable          |
| `check`     | Runs `deploy` in a "dry-run", showing diff-style outputs on tasks indicating changes |
| `vault`     | Opens the Ansible vault file for editing                                             |
| `lint-ci`   | Meant for use with `bdebyl/yamllint` (_see `.drone.yml`_)                            |

