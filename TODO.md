# TODO

## ✅ Caddy Migration - COMPLETED
- [x] Migrate from nginx + ModSecurity to Caddy
- [x] Automatic HTTPS certificate provisioning
- [x] All sites working with proper IP restrictions
- [x] Remove migration_mode logic - Caddy is now default

## Infrastructure Cleanup Tasks

### ✅ Phase 1: System LetsEncrypt to Caddy Migration - COMPLETED
- [x] ~~Create dedicated Caddy certificates volume~~ - Not needed, Caddy manages in /data
- [x] ~~Copy existing system LetsEncrypt certificates~~ - Not needed, Caddy generated new ones
- [x] ~~Set proper permissions~~ - Already correct, Caddy runs as podman user
- [x] Remove LetsEncrypt cron jobs from Ansible (cleanup.yml created)
- [x] Remove LetsEncrypt cron jobs from remote host (both weekly + 5min jobs removed)
- [x] Disable ssl role tasks and certificate generation (disabled in deploy_home.yml)
- [x] ~~Remove certbot installation from common role~~ - Not installed there
- [x] Uninstall certbot/letsencrypt packages from remote host (removed via dnf)
- [x] Stop any running LetsEncrypt services (certbot.timer not running)
- [x] Backup and remove /etc/letsencrypt directory (backup created, directory removed)
- [x] Remove /srv/http/letsencrypt directory (webroot removed)

### ✅ Phase 2: nginx + ModSecurity Cleanup - COMPLETED
- [x] Remove nginx container configuration and tasks (deleted all conf-nginx*.yml, nginx.yml)
- [x] Remove nginx configuration templates and files (removed entire templates/nginx/ directory)
- [x] Remove ModSecurity rules and configuration (removed from defaults/main.yml variables)
- [x] Remove nginx/ModSecurity volume mounts and directories (nginx volume backed up and removed)
- [x] Clean up nginx-related variables from defaults/main.yml (nginx_path removed)
- [x] ~~Remove firewall rules for nginx~~ - Not needed, Caddy uses same ports
- [x] Remove nginx systemd services from remote host (container-nginx service removed)
- [x] ~~Uninstall nginx/ModSecurity packages~~ - Were never system-installed, container-only
- [x] Clean up nginx log directories and files (/var/log/nginx, /var/log/modsecurity removed)
- [x] Remove ModSecurity installation directories (/usr/share/modsecurity, /usr/share/coreruleset removed)
- [x] Create backup of nginx configuration (nginx-backup-{timestamp}.tar.gz created)

### ✅ Phase 3: Final Cleanup - COMPLETED
- [x] Remove Drone CI infrastructure and ci.bdebyl.net host
  - [x] Remove Drone container from podman configuration (drone.yml deleted)
  - [x] Remove ci.bdebyl.net from Caddyfile (site configuration removed)
  - [x] Clean up drone-related volumes and data (drone volume backed up and removed)
  - [x] Update firewall rules to remove CI ports (ports were not explicitly opened)
- [x] Review and remove unused variables and templates
  - [x] Removed ci_server_name variable
  - [x] Removed drone-related variables (drone_path, drone_server_proto, etc.)
  - [x] Cleaned up nginx handler in handlers/main.yml
  - [x] Updated firewall.yml comments
- [x] Update documentation to reflect Caddy as web server
  - [x] Updated CLAUDE.md container organization section
  - [x] Updated tagging strategy (nginx→caddy, drone marked decommissioned)
  - [x] Updated target environment description (nginx→Caddy)
- [x] Verify all services working after cleanup (sites tested and working)