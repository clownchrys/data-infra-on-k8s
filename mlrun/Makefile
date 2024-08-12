ONESHELL: 

##################################
#          MLRUN: Green          #
##################################

# https://docs.mlrun.org/en/stable/install/kubernetes.html
# https://docs.mlrun.org/en/stable/cheat-sheet.html

MLRUN_PREFIX := mlrun
MLRUN_HOME := mlrun

ifneq ($(abspath ${K8S_PROJECT_DIR}), $(abspath .))
$(error Location Error: Please Execute on `K8S_PROJECT_DIR` (Current: $(shell pwd), K8S_PROJECT_DIR: ${K8S_PROJECT_DIR}))
endif

${MLRUN_PREFIX}-%: NAMESPACE := mlrun
${MLRUN_PREFIX}-%: HELM_RELEASE := mlrun
${MLRUN_PREFIX}-%: HELM_CHART := mlrun-ce/mlrun-ce
${MLRUN_PREFIX}-%: HELM_CHART_VERSION := 0.6.2
${MLRUN_PREFIX}-%: HELM_VALUES := ${MLRUN_HOME}/values.yaml

${MLRUN_PREFIX}-%: SECRET_REGISTRY_CREDS := ${MLRUN_HOME}/patches/registry-credentials.gitignored.yaml

${MLRUN_PREFIX}-init:
	helm repo add mlrun-ce https://mlrun.github.io/ce
	helm show values ${HELM_CHART} --version ${HELM_CHART_VERSION} > $(shell echo ${HELM_VALUES} | sed -e 's/.yaml/.default.yaml/')
	touch ${HELM_VALUES}
	$(MAKE) ${MLRUN_PREFIX}-create-secret

# Create Private Docker Registry Credentials
${MLRUN_PREFIX}-create-secret:
	echo -n 'docker-server: '; read DOCKER_SERVER; \
	echo -n 'docker-username: '; read DOCKER_USERNAME; \
	echo 'docker-password: '; read -s DOCKER_PASSWORD; \
	echo -n 'docker-email: '; read DOCKER_EMAIL; \
	mkdir -p $$(dirname ${SECRET_REGISTRY_CREDS}); \
	kubectl create secret docker-registry registry-credentials \
		--docker-server $$DOCKER_SERVER \
		--docker-username $$DOCKER_USERNAME \
		--docker-password $$DOCKER_PASSWORD \
		--docker-email $$DOCKER_EMAIL \
		--dry-run=client \
		--output yaml \
	| yq 'del(.metadata.creationTimestamp)' \
	> ${SECRET_REGISTRY_CREDS}

${MLRUN_PREFIX}-up:
	$(call create_ns, ${NAMESPACE})
	kubectl apply -n ${NAMESPACE} -f ${SECRET_REGISTRY_CREDS} ${OPT_KUBECTL_APPLY}
	helm upgrade -n ${NAMESPACE} ${HELM_RELEASE} ${HELM_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_VALUES} ${OPT_HELM_INSTALL}
	$(call print_url, http, mlrun.geniouslab.io)
	# $(MAKE) ${MLRUN_PREFIX}-account

${MLRUN_PREFIX}-down:
	helm uninstall -n ${NAMESPACE} ${HELM_RELEASE} ${OPT_HELM_UNINSTALL}
	kubectl delete -n ${NAMESPACE} -f ${SECRET_REGISTRY_CREDS} ${OPT_KUBECTL_DELETE}
	kubectl delete ns ${NAMESPACE}

${MLRUN_PREFIX}-account:
	@echo "\nMLFlow Tracking Server:\n"
	@echo "\tUsername: $(shell kubectl get -n ${NAMESPACE} secret/mlflow-tracking -o jsonpath="{ .data.admin-user }" | base64 -d)"
	@echo "\tPassword: $(shell kubectl get -n ${NAMESPACE} secret/mlflow-tracking -o jsonpath="{ .data.admin-password }" | base64 -d)"

${MLRUN_PREFIX}-test: