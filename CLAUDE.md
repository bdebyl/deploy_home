# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a home infrastructure deployment repository using Ansible for automated server configuration and container deployment. The project follows a "one-button deployment" philosophy for managing a home server environment with various self-hosted services.

## Development Commands

### Core Commands
- `make` or `make lint` - Run linting (yamllint + ansible-lint) on all YAML files
- `make deploy` - Deploy all configurations to the home server
- `make deploy TAGS=sometag` - Deploy only specific tagged tasks
- `make deploy TARGET=specific-host` - Deploy to specific host instead of all
- `make check` - Run deployment in dry-run mode showing potential changes
- `make vault` - Edit encrypted Ansible vault file
- `make list-tags` - List all available Ansible tags
- `make list-tasks` - List all Ansible tasks

### Environment Setup
The project uses Python virtualenv for dependency management:
- Dependencies are locked in `requirements.txt` (ansible + yamllint)
- Makefile automatically creates `.venv/` and installs dependencies
- Vault password is sourced from password manager via `.pass.sh`

## Architecture

### Directory Structure
```
ansible/
├── deploy.yml          # Main playbook entry point (imports deploy_home.yml)
├── deploy_home.yml     # Core playbook with role definitions
├── inventories/home/   # Inventory configuration
├── roles/              # Ansible roles organized by function
│   ├── common/        # Base system configuration
│   ├── git/           # Git repository management
│   ├── podman/        # Container orchestration
│   ├── ssl/           # Legacy SSL management (deprecated - Caddy handles certificates automatically)
│   ├── github-actions/# CI/CD runner setup
│   └── pihole/        # DNS filtering
└── vars/
    └── vault.yml      # Encrypted secrets
```

### Container Organization
Containers are organized in `ansible/roles/podman/tasks/containers/`:
- `base/` - Core infrastructure containers (Caddy web server, AWS DDNS)
- `home/` - Home-specific services (Home Assistant, PartKeepr, Immich photos, Nextcloud, Redis)
- `debyltech/` - Personal/business services (Fulfillr)
- `skudak/` - Additional services (BookStack wiki, Nextcloud)

### Security Model
- Ansible vault for encrypted secrets management
- Password sourced from external password manager
- Git-crypt for repository-level encryption (see `.gitattributes`)
- SSH key-based authentication to target hosts
- Caddy provides automatic HTTPS with LetsEncrypt certificates
- Built-in security headers and IP-based access restrictions

## Key Patterns

### Role Structure
Each Ansible role follows standard structure:
- `tasks/main.yml` - Main task entry point
- `defaults/main.yml` - Default variables
- `handlers/main.yml` - Event handlers
- `meta/main.yml` - Role metadata and dependencies

### Container Deployment Pattern
Container tasks follow consistent patterns:
- Firewall configuration
- Container image specification via variables
- Service configuration through imported task files
- Tag-based selective deployment

### Tagging Strategy
Tasks are tagged by service/component for selective deployment:
- `caddy` - Web server tasks (replaced nginx)
- `ddns` - Dynamic DNS tasks
- ~~`drone` - CI/CD tasks (decommissioned)~~
- `hass` - Home Assistant tasks
- Common infrastructure tags like `common`, `ssl`

## Configuration Files

- `ansible.cfg` - Ansible configuration with performance optimizations
- `.yamllint.yml` - YAML linting rules (braces disabled)
- `.lint-vars.sh` - Ansible-lint skip configuration
- `requirements.txt` - Python dependencies with pinned versions

## Target Environment

- Single target host: `home.bdebyl.net`
- OS: Fedora (ansible_user: fedora)
- Container runtime: Podman
- Web server: Caddy with automatic HTTPS and built-in security (replaced nginx + ModSecurity)
- All services accessible via HTTPS with automatic certificate renewal
- ~~CI/CD: Drone CI infrastructure completely decommissioned~~