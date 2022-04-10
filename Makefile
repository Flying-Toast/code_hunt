.PHONY: default
default:
	@echo "No default target; see 'deploy' target"

.PHONY: deploy
deploy:
	podman build . --tag code_hunt_server
	podman save -o code_hunt_server.tar localhost/code_hunt_server:latest
	scp code_hunt_server.tar qwerty.case.edu:~
	rm code_hunt_server.tar
	ssh qwerty.case.edu "podman load -i ~/code_hunt_server.tar && rm code_hunt_server.tar && systemctl --user restart code-hunt-server.service"
