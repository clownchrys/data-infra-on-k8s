###################################
#          HARBOR: Green          #
###################################

SMB_PREFIX := csi-driver-smb
SMB_HOME := csi-driver-smb

ifneq ($(abspath ${K8S_PROJECT_DIR}), $(abspath .))
$(error Location Error: Please Execute on `K8S_PROJECT_DIR` (Current: $(shell pwd), K8S_PROJECT_DIR: ${K8S_PROJECT_DIR}))
endif

${SMB_PREFIX}-%: NAMESPACE := kube-system
${SMB_PREFIX}-%: KUSTOMIZATION := ${SMB_HOME}

# NOTE: THIS WILL BE EXECUTED, due to no credentials file!!
${SMB_PREFIX}-init:
	echo "username=$$(yq '.smb-storage.username' credentials.gitignored.yaml)" \
	> ${SMB_HOME}/patches/smb-creds.gitignored.env
	echo "password=$$(yq '.smb-storage.password' credentials.gitignored.yaml)" \
	>> ${SMB_HOME}/patches/smb-creds.gitignored.env
	yq " \
		with(.[] | select(.path == \"/parameters/source\"); .value = \"$$(yq '.smb-storage.source' credentials.gitignored.yaml)\") | \
		with(.[[filter(.path == \"/mountOptions/-\" and .value == \"<REDACTED>\") | .[] | path] | flatten | min]; .value = \"port=$$(yq '.smb-storage.ports.smb' credentials.gitignored.yaml)\") | \
		with(.[[filter(.path == \"/mountOptions/-\" and .value == \"<REDACTED>\") | .[] | path] | flatten | min]; .value = \"port=$$(yq '.smb-storage.ports.netbios' credentials.gitignored.yaml)\") \
	" ${SMB_HOME}/patches/smb-server.yaml.template \
	> ${SMB_HOME}/patches/smb-server-patch.gitignored.yaml

${SMB_PREFIX}-up:
	$(call create_ns, ${NAMESPACE})
	kustomize build --enable-helm ${KUSTOMIZATION} | kubectl apply -n ${NAMESPACE} ${OPT_KUBECTL_APPLY} --wait -f -

${SMB_PREFIX}-down:
	kustomize build --enable-helm ${KUSTOMIZATION} | yq '[.]' | yq 'reverse | .[] | split_doc' | kubectl delete ${OPT_KUBECTL_DELETE} -f -
	kubectl delete ns ${NAMESPACE}
