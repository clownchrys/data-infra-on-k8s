##################################
#          KIND-CLUSTER          #
##################################

KIND_PREFIX := kind
KIND_HOME := cluster/kind

ifneq ($(abspath ${K8S_PROJECT_DIR}), $(abspath .))
$(error Location Error: Please Execute on `K8S_PROJECT_DIR` (Current: $(shell pwd), K8S_PROJECT_DIR: ${K8S_PROJECT_DIR}))
endif

${KIND_PREFIX}-%: KIND_IMAGE := kindest/node:v1.29.2
${KIND_PREFIX}-%: KIND_CLUSTER_NAME := kind
${KIND_PREFIX}-%: OPT_DISABLE_DEFAULT_CNI := false

${KIND_PREFIX}-%: CONFIG_YAML := ${KIND_HOME}/kind-config.yaml
${KIND_PREFIX}-%: PATCH_KUBE_ADMIN := ${KIND_HOME}/patches/kube-admin.yaml
${KIND_PREFIX}-%: PATCH_STORAGE_CLASS := ${KIND_HOME}/patches/storageclass.yaml

${KIND_PREFIX}-up:
	kind create cluster \
		--name ${KIND_CLUSTER_NAME} \
		--image ${KIND_IMAGE} \
		--config - <<(cat ${CONFIG_YAML} | yq ".networking.disableDefaultCNI=${OPT_DISABLE_DEFAULT_CNI}")
	kubectl get node -l node-role.kubernetes.io/control-plane!= -o yaml | yq '.items[] | .metadata.name' | xargs -I {} kubectl label node {} node-role.kubernetes.io/worker=
	kubectl apply -n kube-system -f ${PATCH_KUBE_ADMIN} ${OPT_KUBECTL_APPLY}
	kubectl apply -f ${PATCH_STORAGE_CLASS} ${OPT_KUBECTL_APPLY}

${KIND_PREFIX}-down:
	kind delete cluster --name ${KIND_CLUSTER_NAME} -v 5

${KIND_PREFIX}-log:
	rm -rvf ${KIND_HOME}/.logs
	kind export logs --name ${KIND_CLUSTER_NAME} ${KIND_HOME}/.logs -v5

${KIND_PREFIX}-freeze:
	@echo containers freezeing...
	docker ps --format='{{ .Names }}' | grep -E '^kind-' | xargs -I {} docker pause {}

${KIND_PREFIX}-melt:
	@echo containers melting...
	docker ps --format='{{ .Names }}' | grep -E '^kind-' | xargs -I {} docker unpause {}
