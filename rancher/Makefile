####################################
#          RANCHER: Green          #
####################################

RANCHER := rancher
RANCHER_HOME := rancher

ifneq ($(abspath ${K8S_PROJECT_DIR}), $(abspath .))
$(error Location Error: Please Execute on `K8S_PROJECT_DIR` (Current: $(shell pwd), K8S_PROJECT_DIR: ${K8S_PROJECT_DIR}))
endif

${RANCHER}-%: NAMESPACE := cattle-system
${RANCHER}-%: HELM_RELEASE := rancher
${RANCHER}-%: HELM_CHART := rancher-stable/rancher
${RANCHER}-%: HELM_CHART_VERSION := 2.8.5
${RANCHER}-%: HELM_VALUES := ${RANCHER_HOME}/values.yaml

# https://ranchermanager.docs.rancher.com/faq/rancher-is-no-longer-needed#what-if-i-dont-want-rancher-anymore
# https://github.com/rancher/rancher-cleanup
${RANCHER}-%: PATCH_CLEAN_UP := https://raw.githubusercontent.com/rancher/rancher-cleanup/main/deploy/rancher-cleanup.yaml

${RANCHER}-init:
	helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
	helm show values ${HELM_CHART} --version ${HELM_CHART_VERSION} > $(shell echo ${HELM_VALUES} | sed -e 's/.yaml/.default.yaml/')
	touch ${HELM_VALUES}

${RANCHER}-up:
	helm upgrade -n ${NAMESPACE} ${HELM_RELEASE} ${HELM_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_VALUES} ${OPT_HELM_INSTALL}
	$(call print_url, https, rancher.geniouslab.io)

${RANCHER}-down:
	kubectl apply -f ${PATCH_CLEAN_UP} ${OPT_KUBECTL_APPLY}
	kubectl wait -n kube-system job/cleanup-job --for=condition=complete --timeout=1h
	kubectl delete -f ${PATCH_CLEAN_UP} ${OPT_KUBECTL_DELETE}
	helm uninstall -n ${NAMESPACE} ${HELM_RELEASE} ${OPT_HELM_UNINSTALL}
	@echo '[WARNING] please re-create istio-system, if needed'
