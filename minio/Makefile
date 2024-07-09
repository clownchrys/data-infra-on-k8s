##################################
#          MINIO: Green          #
##################################

MINIO := minio

ifneq (${ROOT_DIR}, $(abspath .))
$(error Location Error: Please Execute on Top-Level Directory (Current: $(shell pwd)))
endif

${MINIO}-%: NAMESPACE := minio
${MINIO}-%: HELM_RELEASE := minio
${MINIO}-%: HELM_CHART := bitnami/minio
${MINIO}-%: HELM_CHART_VERSION := 14.4.1
${MINIO}-%: HELM_VALUES := ${MINIO}/values.yaml

${MINIO}-init:
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm show values ${HELM_CHART} --version ${HELM_CHART_VERSION} > $(shell echo ${HELM_VALUES} | sed -e 's/.yaml/.default.yaml/')
	touch ${HELM_VALUES}

${MINIO}-up:
	helm upgrade -n ${NAMESPACE} ${HELM_RELEASE} ${HELM_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_VALUES} ${OPT_HELM_INSTALL}
	kubectl annotate -n ${NAMESPACE} secret/minio reflector.v1.k8s.emberstack.com/reflection-allowed=true
	$(call print_url, http, console.minio.geniouslab.io)
	$(call print_url, http, api.minio.geniouslab.io)

${MINIO}-down:
	helm uninstall -n ${NAMESPACE} ${HELM_RELEASE} ${OPT_HELM_UNINSTALL}
	kubectl delete -n ${NAMESPACE} pvc --all ${OPT_KUBECTL_DELETE}

${MINIO}-account:
	@echo Username: $(shell kubectl get secret/minio -n minio -o yaml | yq '.data.root-user' | base64 -d)
	@echo Password: $(shell kubectl get secret/minio -n minio -o yaml | yq '.data.root-password' | base64 -d)