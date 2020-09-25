#               __       ____ __
#   __ _  ___ _/ /_____ / _(_) /__
#  /  ' \/ _ `/  '_/ -_) _/ / / -_)
# /_/_/_/\_,_/_/\_\\__/_//_/_/\__/
#
# Author: bdebyl (Bastian de Byl)
all: lint

# Default to all ansible tags to run (passed via 'make deploy TAGS=sometag')
TAGS?=all

PASS_SRC=./.pass.sh
# Setup Definitions
VENV=.venv
VENV_BIN=.venv/bin
PIP=${VENV_BIN}/pip
ANSIBLE=${VENV_BIN}/ansible-playbook
ANSIBLE_VAULT=${VENV_BIN}/ansible-vault

LINT_ANSIBLE=${VENV_BIN}/ansible-lint
LINT_YAML=${VENV_BIN}/yamllint

VAULT_PASS_FILE=.ansible-vaultpass
VAULT_FILE=ansible/vars/vault.yml

# Variables
ANSIBLE_INVENTORY=ansible/inventories/home/hosts.yml
SSH_KEY=${HOME}/.ssh/id_rsa_home_ansible

${VENV}:
	virtualenv -p python3 ${VENV}
${PIP}: ${VENV}

${ANSIBLE} ${ANSIBLE_VAULT} ${LINT_YAML} ${LINT_ANSIBLE}: ${VENV} requirements.txt
	${PIP} install -r requirements.txt
	touch $@

${VAULT_PASS_FILE}: ${ANSIBLE}
	. ${PASS_SRC}; pass $$PASS_LOC > $@

${VAULT_FILE}: ${VAULT_PASS_FILE}
	${ANSIBLE_VAULT} create --vault-password-file ${VAULT_PASS_FILE} $@

# Linting
YAML_FILES=$(shell find ansible/ -name '*.yml' -not -name '*vault*')

# Ansible Lint skip list (https://ansible-lint.readthedocs.io/en/latest/default_rules.html)
# [701] - "No 'galaxy_info' found (in role)"
ANSIBLE_LINT_SKIP_LIST=701

# Targets
deploy: ${ANSIBLE} ${VAULT_FILE}
	${ANSIBLE} --diff --private-key ${SSH_KEY} -t ${TAGS} -i ${ANSIBLE_INVENTORY} --vault-password-file ${VAULT_PASS_FILE} ansible/deploy.yml

check: ${ANSIBLE} ${VAULT_FILE}
	${ANSIBLE} --check --diff --private-key ${SSH_KEY} -t ${TAGS} -i ${ANSIBLE_INVENTORY} --vault-password-file ${VAULT_PASS_FILE} ansible/deploy.yml

vault: ${ANSIBLE_VAULT} ${VAULT_FILE}
	${ANSIBLE_VAULT} edit --vault-password-file ${VAULT_PASS_FILE} ${VAULT_FILE}

lint: ${LINT_YAML} ${LINT_ANSIBLE}
	@printf "Running yamllint...\n"
	-@${LINT_YAML} ${YAML_FILES}
	@printf "Running ansible-lint with SKIP_LIST: [%s]...\n" "${ANSIBLE_LINT_SKIP_LIST}"
	-@${LINT_ANSIBLE} -x ${ANSIBLE_LINT_SKIP_LIST} ${YAML_FILES}
