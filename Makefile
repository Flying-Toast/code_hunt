.PHONY: default
default:
	@echo "No default target; see 'deploy' target"

.PHONY: deploy
deploy:
	podman build . --tag code_hunt_server
	podman save -o code_hunt_server.tar localhost/code_hunt_server:latest
	scp code_hunt_server.tar qwerty.case.edu:~
	rm code_hunt_server.tar
	ssh qwerty.case.edu "podman load -i ~/code_hunt_server.tar && rm code_hunt_server.tar && systemctl --user stop code-hunt-server.service && podman run --env-file /home/simon/code_hunt/VARS.env -v /home/simon/code_hunt/db/:/var/code_hunt/db:rw,U --rm localhost/code_hunt_server:latest /app/bin/migrate && systemctl --user restart code-hunt-server.service"
