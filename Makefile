#               __       ____ __
#   __ _  ___ _/ /_____ / _(_) /__
#  /  ' \/ _ `/  '_/ -_) _/ / / -_)
# /_/_/_/\_,_/_/\_\\__/_//_/_/\__/
#
# Author: bdebyl (Bastian de Byl)
all: lint

PASS_SRC=./.pass.sh
# Setup Definitions
VENV=.venv
VENV_BIN=.venv/bin
PIP=${VENV_BIN}/pip
ANSIBLE=${VENV_BIN}/ansible-playbook
ANSIBLE_VAULT=${VENV_BIN}/ansible-vault

LINT_YAML=${VENV_BIN}/yamllint

VAULT_PASS_FILE=.ansible-vaultpass
VAULT_FILE=ansible/vars/vault.yml

# Variables
ANSIBLE_INVENTORY=ansible/inventories/home/hosts.yml
#SSH_KEY=${HOME}/.ssh/id_rsa_home_ansible

# Default to all ansible tags to run (passed via 'make deploy TAGS=sometag')
TAGS?=all
SKIP_TAGS?=none
TARGET?=all
EXTRA_VARS?=

${VENV}:
	python3 -m venv ${VENV}
${PIP}: ${VENV}

${ANSIBLE} ${ANSIBLE_VAULT} ${LINT_YAML}: ${VENV} requirements.txt
	${PIP} install -r requirements.txt
	touch $@

${VAULT_PASS_FILE}: ${ANSIBLE}
	. ${PASS_SRC}; pass $$PASS_LOC > $@

${VAULT_FILE}: ${VAULT_PASS_FILE}
	if [ ! -e "${VAULT_FILE}" ]; then \
		${ANSIBLE_VAULT} create --vault-password-file ${VAULT_PASS_FILE} $@; \
	fi
	touch $@

# Linting
YAML_FILES=$(shell find ansible/ -name '*.yml' -not -name '*vault*')
SKIP_FILE=./.lint-vars.sh

# Targets
deploy: ${ANSIBLE} ${VAULT_FILE}
	${ANSIBLE} --diff -t ${TAGS} --skip-tags ${SKIP_TAGS} -i ${ANSIBLE_INVENTORY} -l ${TARGET} --vault-password-file ${VAULT_PASS_FILE} $(if ${EXTRA_VARS},-e "${EXTRA_VARS}") ansible/deploy.yml

list-tags: ${ANSIBLE} ${VAULT_FILE}
	${ANSIBLE} --list-tags -i ${ANSIBLE_INVENTORY} -l ${TARGET} --vault-password-file ${VAULT_PASS_FILE} ansible/deploy.yml

list-tasks: ${ANSIBLE} ${VAULT_FILE}
	${ANSIBLE} --list-tasks -i ${ANSIBLE_INVENTORY} -l ${TARGET} --vault-password-file ${VAULT_PASS_FILE} ansible/deploy.yml

check: ${ANSIBLE} ${VAULT_FILE}
	${ANSIBLE} --check --diff -t ${TAGS} --skip-tags ${SKIP_TAGS} -i ${ANSIBLE_INVENTORY} -l ${TARGET} --vault-password-file ${VAULT_PASS_FILE} $(if ${EXTRA_VARS},-e "${EXTRA_VARS}") ansible/deploy.yml

vault: ${ANSIBLE_VAULT} ${VAULT_FILE}
	${ANSIBLE_VAULT} edit --vault-password-file ${VAULT_PASS_FILE} ${VAULT_FILE}

lint: ${LINT_YAML} ${SKIP_FILE}
	@printf "Running yamllint...\n"
	-@${LINT_YAML} ${YAML_FILES}
