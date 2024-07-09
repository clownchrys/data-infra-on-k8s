##################################
#          KIND-CLUSTER          #
##################################

KIND := kind
KIND_HOME := cluster/kind

ifneq (${ROOT_DIR}, $(abspath .))
$(error Location Error: Please Execute on Top-Level Directory (Current: $(shell pwd)))
endif

${KIND}-%: IMAGE := kindest/node:v1.29.2
${KIND}-%: CONFIG_FILE := ${KIND_HOME}/kind-config.yaml
${KIND}-%: CLUSTER_NAME := kind
${KIND}-%: OPT_DISABLE_DEFAULT_CNI := true

${KIND}-%: PATCH_KUBE_ADMIN := ${KIND_HOME}/patches/kube-admin.yaml
${KIND}-%: PATCH_STORAGE_CLASS := ${KIND_HOME}/patches/storageclass.yaml

${KIND}-check:
	cat ${CONFIG_FILE} | yq '.networking.disableDefaultCNI' | xargs -I {} [ "{}" = "${OPT_DISABLE_DEFAULT_CNI}" ]

# $(shell kind create cluster --name ${CLUSTER_NAME} --image=${IMAGE} --config <(cat ${CONFIG_FILE} | yq ".networking.disableDefaultCNI=${OPT_DISABLE_DEFAULT_CNI}"))
${KIND}-up: ${KIND}-check
	kind create cluster --name ${CLUSTER_NAME} --image=${IMAGE} --config ${CONFIG_FILE}
	kubectl get node -l node-role.kubernetes.io/control-plane!= -o yaml | yq '.items[] | .metadata.name' | xargs -I {} kubectl label node {} node-role.kubernetes.io/worker=
	kubectl apply -n kube-system -f ${PATCH_KUBE_ADMIN} ${OPT_KUBECTL_APPLY}
	kubectl apply -f ${PATCH_STORAGE_CLASS} ${OPT_KUBECTL_APPLY}

${KIND}-down:
	kind delete cluster --name ${CLUSTER_NAME} -v 5

${KIND}-log:
	rm -rvf ${KIND_HOME}/.logs
	kind export logs --name ${CLUSTER_NAME} ${KIND_HOME}/.logs -v5

${KIND}-freeze:
	@echo containers freezeing...
	docker ps --format='{{ .Names }}' | grep -E '^kind-' | xargs -I {} docker pause {}

${KIND}-melt:
	@echo containers melting...
	docker ps --format='{{ .Names }}' | grep -E '^kind-' | xargs -I {} docker unpause {}
