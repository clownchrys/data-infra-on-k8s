#####################################
#          KUBEVIEW: Green          #
#####################################

KUBEVIEW := kubeview

ifneq (${ROOT_DIR}, $(abspath .))
$(error Location Error: Please Execute on Top-Level Directory (Current: $(shell pwd)))
endif

${KUBEVIEW}-%: NAMESPACE := kubeview
${KUBEVIEW}-%: HELM_RELEASE := kubeview
${KUBEVIEW}-%: HELM_CHART := kubeview/kubeview
${KUBEVIEW}-%: HELM_CHART_VERSION := 0.1.31
${KUBEVIEW}-%: HELM_VALUES := ${KUBEVIEW}/values.yaml

${KUBEVIEW}-init:
	helm repo add kubeview https://benc-uk.github.io/kubeview/charts
	helm show values ${HELM_CHART} --version ${HELM_CHART_VERSION} > $(shell echo ${HELM_VALUES} | sed -e 's/.yaml/.default.yaml/')
	touch ${HELM_VALUES}

${KUBEVIEW}-up:
	helm upgrade -n ${NAMESPACE} ${HELM_RELEASE} ${HELM_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_VALUES} ${OPT_HELM_INSTALL}
	$(call print_url, http, kubeview.geniouslab.io)

${KUBEVIEW}-down:
	helm uninstall -n ${NAMESPACE} ${HELM_RELEASE} ${OPT_HELM_UNINSTALL}
