IMAGE_NAME := claude-code-runner
HOST_UID := $(shell id -u)
HOST_GID := $(shell id -g)

.PHONY: build rebuild clean run shell help

help:
	@echo "Claude Code Container"
	@echo ""
	@echo "Usage:"
	@echo "  make build    - Build the container image"
	@echo "  make rebuild  - Force rebuild (no cache)"
	@echo "  make run      - Run claude in current directory"
	@echo "  make shell    - Open bash shell in container"
	@echo "  make clean    - Remove the container image"
	@echo ""
	@echo "Claude mounted from host, Docker CLI installed in container"

build:
	docker build -t $(IMAGE_NAME) .

rebuild:
	docker build --no-cache -t $(IMAGE_NAME) .

clean:
	docker rmi $(IMAGE_NAME) 2>/dev/null || true

run:
	./run-claude.sh .

shell:
	docker run -it --rm \
		-v $(PWD):$(PWD) \
		-w $(PWD) \
		-v $(HOME)/.claude:$(HOME)/.claude \
		-v $(HOME)/.claude.json:$(HOME)/.claude.json \
		-v $(HOME)/.config:$(HOME)/.config:ro \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-e HOST_UID=$(HOST_UID) \
		-e HOST_GID=$(HOST_GID) \
		-e HOST_HOME=$(HOME) \
		-e DOCKER_HOST=unix:///var/run/docker.sock \
		--entrypoint /bin/bash \
		$(IMAGE_NAME) -c '\
			groupadd -g $(HOST_GID) -o claude 2>/dev/null || true; \
			useradd -u $(HOST_UID) -g $(HOST_GID) -o -M -d $(HOME) claude 2>/dev/null || true; \
			if [ -S /var/run/docker.sock ]; then \
				DOCKER_GID=$$(stat -c "%g" /var/run/docker.sock); \
				groupadd -g $$DOCKER_GID -o docker 2>/dev/null || true; \
				usermod -aG docker claude 2>/dev/null || true; \
			fi; \
			sudo -u claude HOME=$(HOME) DOCKER_HOST=unix:///var/run/docker.sock bash'
