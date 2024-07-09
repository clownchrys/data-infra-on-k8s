#########################################
#          CERT_MANAGER: Green          #
#########################################

# https://cert-manager.io/docs/installation/helm/

CERT_MANAGER := cert-manager

ifneq (${ROOT_DIR}, $(abspath .))
$(error Location Error: Please Execute on Top-Level Directory (Current: $(shell pwd)))
endif

${CERT_MANAGER}-%: NAMESPACE := cert-manager
${CERT_MANAGER}-%: HELM_RELEASE := cert-manager
${CERT_MANAGER}-%: HELM_CHART := jetstack/cert-manager
${CERT_MANAGER}-%: HELM_CHART_VERSION := v1.14.5
${CERT_MANAGER}-%: HELM_VALUES := ${CERT_MANAGER}/values.yaml
${CERT_MANAGER}-%: PATCH_CLUSTER_CERT := ${CERT_MANAGER}/patches/cluster-local-cert.yaml

${CERT_MANAGER}-init:
	helm repo add jetstack https://charts.jetstack.io
	helm pull jetstack/cert-manager --destination ./${CERT_MANAGER}
	helm show values ${HELM_CHART} --version ${VERSION} > $(shell echo ${HELM_VALUES} | sed -e 's/.yaml/.default.yaml/')
	touch ./${CERT_MANAGER}/values.yaml

${CERT_MANAGER}-up:
	helm upgrade -n ${NAMESPACE} ${HELM_RELEASE} ${HELM_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_VALUES} ${OPT_HELM_INSTALL}
	kubectl apply -f ${PATCH_CLUSTER_CERT} ${OPT_KUBECTL_APPLY}

${CERT_MANAGER}-down:
	kubectl delete -f ${PATCH_CLUSTER_CERT} ${OPT_KUBECTL_DELETE}
	helm uninstall -n ${NAMESPACE} ${HELM_RELEASE} ${OPT_HELM_UNINSTALL}
