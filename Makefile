.PHONY: apply full help profile status
.DEFAULT_GOAL := help

help:
	@echo "Available targets:"
	@echo "  profile <n> - Set profile (personal or work)"
	@echo "  status         - Show current profile and status"
	@echo "  apply          - Apply macOS configuration (default, no sudo commands)"
	@echo "  full           - Apply full macOS configuration (includes system-level settings)"
	@echo "  help           - Show this help message"
	@echo ""
	@if [ -f .profile ]; then \
		echo "Current profile: $$(cat .profile)"; \
	else \
		echo "No profile set. Please run 'make profile <name>' first."; \
	fi

status:
	@bash scripts/status.sh

profile:
	@if [ "$(word 2,$(MAKECMDGOALS))" != "" ]; then \
		bash scripts/profile.sh "$(word 2,$(MAKECMDGOALS))"; \
	else \
		echo "Usage: make profile <name>"; \
		echo "Available profiles: personal, work"; \
		exit 1; \
	fi

personal work:
	@# These targets are handled by the profile target above

apply:
	@bash scripts/apply.sh

full:
	@echo "Running full macOS configuration (includes system-level settings)..."
	@echo "This mode requires administrator privileges. Please enter your password:"
	@sudo -v
	@MACOS_CONFIG_FULL=1 bash scripts/apply.sh
