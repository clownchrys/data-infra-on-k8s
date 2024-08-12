#####################################
#          KUBEFLOW: Green          #
#####################################

# Ref.
# https://github.com/kubeflow/examples

KUBEFLOW_PREFIX := kubeflow
KUBEFLOW_HOME := kubeflow

ifneq ($(abspath ${K8S_PROJECT_DIR}), $(abspath .))
$(error Location Error: Please Execute on `K8S_PROJECT_DIR` (Current: $(shell pwd), K8S_PROJECT_DIR: ${K8S_PROJECT_DIR}))
endif

${KUBEFLOW_PREFIX}-%: KUBEFLOW_MANIFEST_DIR := ${KUBEFLOW_HOME}/manifests
${KUBEFLOW_PREFIX}-%: KUSTOMIZATION := ${KUBEFLOW_HOME}/kustomize/v1.9.0

${KUBEFLOW_PREFIX}-%: TEMPLATE_CREATE_PROFILE := ${KUBEFLOW_HOME}/templates/profile.create.yaml
${KUBEFLOW_PREFIX}-%: TEMPLATE_JOIN_PROFILE := ${KUBEFLOW_HOME}/templates/profile.join.yaml

${KUBEFLOW_PREFIX}-init:
	git submodule update --init --recursive ${KUBEFLOW_MANIFEST_DIR}
	cd ${KUBEFLOW_MANIFEST_DIR} && git checkout tags/$$(basename ${KUSTOMIZATION})
	mkdir -p ${KUSTOMIZATION}
	if [ ! -f ${KUSTOMIZATION}/kustomization.yaml ]; then \
		cat ${KUBEFLOW_MANIFEST_DIR}/example/kustomization.yaml | sed 's/\.\.\//\.\.\/\.\.\/manifests\//' > ${KUSTOMIZATION}/kustomization.yaml; \
		echo "\n[INFO] ${KUSTOMIZATION}/kustomization.yaml generated..."; \
	else \
		echo "\n[INFO] ${KUSTOMIZATION}/kustomization.yaml already exists..."; \
	fi
	@echo "[INFO] Add lines in ${KUSTOMIZATION}/kustomization.yaml, if you need..."

${KUBEFLOW_PREFIX}-tmp:
	# $(MAKE) ${KUBEFLOW_PREFIX}-create-profile ACTION=apply PROFILE_NAME=kubeflow-test-space RAW_OWNER_EMAIL=admin@clownchrys.link
	# $(MAKE) ${KUBEFLOW_PREFIX}-join-profile ACTION=apply PROFILE_NAME=kubeflow-admin-space RAW_USER_EMAIL=user@example.com SAFE_USER_EMAIL=user-example-com USER_ROLE=edit

${KUBEFLOW_PREFIX}-up:
	cd ${KUBEFLOW_MANIFEST_DIR} && git checkout tags/$$(basename ${KUSTOMIZATION})
	kustomize build ${KUSTOMIZATION} >> /dev/null
	while ! kustomize build ${KUSTOMIZATION} | kubectl apply ${OPT_KUBECTL_APPLY} -f -; do echo "Retrying to apply resources"; sleep 10; done	
	$(MAKE) ${KUBEFLOW_PREFIX}-create-profile ACTION=apply PROFILE_NAME=kubeflow-admin-space RAW_OWNER_EMAIL=admin@clownchrys.link
	# $(MAKE) ${KUBEFLOW_PREFIX}-join-profile ACTION=apply PROFILE_NAME=kubeflow-admin-space RAW_USER_EMAIL=user@clownchrys.link SAFE_USER_EMAIL=user-clownchrys-link USER_ROLE=view
	$(call print_url, https, kubeflow.geniouslab.io)

${KUBEFLOW_PREFIX}-down:
	$(MAKE) ${KUBEFLOW_PREFIX}-create-profile ACTION=delete PROFILE_NAME=kubeflow-admin-space RAW_OWNER_EMAIL=admin@clownchrys.link
	# $(MAKE) ${KUBEFLOW_PREFIX}-join-profile ACTION=delete PROFILE_NAME=kubeflow-admin-space RAW_USER_EMAIL=user@clownchrys.link SAFE_USER_EMAIL=user-clownchrys-link USER_ROLE=view
	kustomize build ${KUSTOMIZATION} | yq '[.]' | yq '. | reverse | .[] | split_doc | select(.kind == "CustomResourceDefinition")' >> /dev/null
	while ! kustomize build ${KUSTOMIZATION} | yq '[.]' | yq '. | reverse | .[] | split_doc | select(.kind == "CustomResourceDefinition")' | kubectl delete ${OPT_KUBECTL_DELETE} -f -; do echo "Retrying to delete resources"; sleep 10; done	
	while ! kustomize build ${KUSTOMIZATION} | yq '[.]' | yq '. | reverse | .[] | split_doc | select(.kind != "CustomResourceDefinition")' | kubectl delete ${OPT_KUBECTL_DELETE} -f -; do echo "Retrying to delete resources"; sleep 10; done	

${KUBEFLOW_PREFIX}-create-profile:
	$(call check_defined, ACTION PROFILE_NAME RAW_OWNER_EMAIL)
	sed \
	-e 's/<PROFILE_NAME>/${PROFILE_NAME}/g' \
	-e 's/<RAW_OWNER_EMAIL>/${RAW_OWNER_EMAIL}/g' \
	${TEMPLATE_CREATE_PROFILE} \
	| kubectl ${ACTION} ${OPT_KUBECTL_$(shell echo ${ACTION} | tr '[:lower:]' '[:upper:]')} -f -

${KUBEFLOW_PREFIX}-join-profile:
	$(call check_defined, ACTION PROFILE_NAME RAW_USER_EMAIL SAFE_USER_EMAIL USER_ROLE)
ifeq ($(shell [ '${ACTION}' = 'apply' ] && echo 1 || echo 0), 1)
	while ! kubectl wait ns ${PROFILE_NAME} --for jsonpath='{.status.phase}=Active'; do echo 'retrying...'; sleep 10; done
endif
	sed \
	-e 's/<PROFILE_NAME>/${PROFILE_NAME}/g' \
	-e 's/<RAW_USER_EMAIL>/${RAW_USER_EMAIL}/g' \
	-e 's/<SAFE_USER_EMAIL>/${SAFE_USER_EMAIL}/g' \
	-e 's/<USER_ROLE>/${USER_ROLE}/g' \
	${TEMPLATE_JOIN_PROFILE} \
	| kubectl ${ACTION} ${OPT_KUBECTL_$(shell echo ${ACTION} | tr '[:lower:]' '[:upper:]')} -f -
