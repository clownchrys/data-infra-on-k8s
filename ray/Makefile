##############################
#          RAY: Red          #
##############################

RAY := ray

ifneq (${ROOT_DIR}, $(abspath .))
$(error Location Error: Please Execute on Top-Level Directory (Current: $(shell pwd)))
endif

${RAY}-%: NAMESPACE := ray

${RAY}-%: HELM_RELEASE := raycluster
${RAY}-%: HELM_CHART := kuberay/ray-cluster
${RAY}-%: HELM_CHART_VERSION := 1.1.1
${RAY}-%: HELM_VALUES := ${RAY}/values.cluster.yaml

${RAY}-%: KUBERAY_HELM_RELEASE := kuberay
${RAY}-%: KUBERAY_HELM_CHART := kuberay/kuberay-operator
${RAY}-%: KUBERAY_HELM_CHART_VERSION := 1.1.1
${RAY}-%: KUBERAY_HELM_VALUES := ${RAY}/values.operator.yaml

${RAY}-init:
	@helm repo add kuberay https://ray-project.github.io/kuberay-helm
	@helm show values ${HELM_CHART} --version ${HELM_CHART_VERSION} > $(shell echo ${HELM_VALUES} | sed -e 's/.yaml/.default.yaml/')
	@helm show values ${KUBERAY_HELM_CHART} --version ${KUBERAY_HELM_CHART_VERSION} > $(shell echo ${KUBE_RAY_HELM_VALUES} | sed -e 's/.yaml/.default.yaml/')
	@touch ${HELM_VALUES}
	@touch ${KUBERAY_HELM_VALUES}

# https://docs.ray.io/en/latest/cluster/kubernetes/getting-started/raycluster-quick-start.html#kuberay-raycluster-quickstart
${RAY}-up:
	@helm upgrade -n ${NAMESPACE} ${KUBERAY_HELM_RELEASE} ${KUBERAY_HELM_CHART} --version ${KUBERAY_HELM_CHART_VERSION} -f ${KUBERAY_HELM_VALUES} ${OPT_HELM_INSTALL}
	@helm upgrade -n ${NAMESPACE} ${HELM_RELEASE} ${HELM_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_VALUES} ${OPT_HELM_INSTALL}

${RAY}-down:
	@helm uninstall -n ${NAMESPACE} ${HELM_RELEASE} ${OPT_HELM_UNINSTALL}
	@helm uninstall -n ${NAMESPACE} ${KUBERAY_HELM_RELEASE} ${OPT_HELM_UNINSTALL}
