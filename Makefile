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

# Targets
deploy: ${ANSIBLE} ${VAULT_PASS_FILE}
	${ANSIBLE} --diff --private-key ${SSH_KEY} -t ${TAGS} -i ${ANSIBLE_INVENTORY} --vault-password-file ${VAULT_PASS_FILE} ansible/deploy.yml

check: ${ANSIBLE} ${VAULT_PASS_FILE}
	${ANSIBLE} --check --diff --private-key ${SSH_KEY} -t ${TAGS} -i ${ANSIBLE_INVENTORY} --vault-password-file ${VAULT_PASS_FILE} ansible/deploy.yml

encrypt-string: ${ANSIBLE_VAULT} ${VAULT_PASS_FILE}
	${ANSIBLE_VAULT} encrypt_string --vault-password-file ${VAULT_PASS_FILE}

lint: ${LINT_YAML} ${LINT_ANSIBLE}
	@${LINT_YAML} ansible/
	@${LINT_ANSIBLE} ansible/
