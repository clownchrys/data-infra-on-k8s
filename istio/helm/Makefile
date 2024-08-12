# ${ISTIO_PREFIX}-%: NAMESPACE := istio-system
# ${ISTIO_PREFIX}-%: HELM_CHART_VERSION := 1.16.0
# ${ISTIO_PREFIX}-%: HELM_BASE_RELEASE := istio-base
# ${ISTIO_PREFIX}-%: HELM_BASE_CHART := istio/base
# ${ISTIO_PREFIX}-%: HELM_BASE_VALUES := ${ISTIO_HOME}/values.base.yaml
# ${ISTIO_PREFIX}-%: HELM_ISTIOD_RELEASE := istio-istiod
# ${ISTIO_PREFIX}-%: HELM_ISTIOD_CHART := istio/istiod
# ${ISTIO_PREFIX}-%: HELM_ISTIOD_VALUES := ${ISTIO_HOME}/values.istiod.yaml
# ${ISTIO_PREFIX}-%: HELM_GATEWAY_RELEASE := istio-ingressgateway
# ${ISTIO_PREFIX}-%: HELM_GATEWAY_CHART := istio/gateway
# ${ISTIO_PREFIX}-%: HELM_GATEWAY_VALUES := ${ISTIO_HOME}/values.gateway.yaml

# ${ISTIO_PREFIX}-init:
# 	helm repo add istio https://istio-release.storage.googleapis.com/charts
# 	helm show values ${HELM_BASE_CHART} --version ${HELM_CHART_VERSION} > ./${ISTIO_HOME}/values.base.default.yaml
# 	helm show values ${HELM_ISTIOD_CHART} --version ${HELM_CHART_VERSION} > ./${ISTIO_HOME}/values.istiod.default.yaml
# 	helm show values ${HELM_GATEWAY_CHART} --version ${HELM_CHART_VERSION} > ./${ISTIO_HOME}/values.gateway.default.yaml
# 	touch ${HELM_BASE_VALUES}
# 	touch ${HELM_ISTIOD_VALUES}
# 	touch ${HELM_GATEWAY_VALUES}

# ${ISTIO_PREFIX}-up:
# 	helm upgrade -n ${NAMESPACE} ${HELM_BASE_RELEASE} ${HELM_BASE_CHART} -f ${HELM_BASE_VALUES} --version ${HELM_CHART_VERSION} ${OPT_HELM_INSTALL}
# 	helm upgrade -n ${NAMESPACE} ${HELM_ISTIOD_RELEASE} ${HELM_ISTIOD_CHART} -f ${HELM_ISTIOD_VALUES} --version ${HELM_CHART_VERSION} ${OPT_HELM_INSTALL}
# 	helm upgrade -n ${NAMESPACE} ${HELM_GATEWAY_RELEASE} ${HELM_GATEWAY_CHART} -f ${HELM_GATEWAY_VALUES} --version ${HELM_CHART_VERSION} ${OPT_HELM_INSTALL}

# ${ISTIO_PREFIX}-down:
# 	helm uninstall -n ${NAMESPACE} ${HELM_BASE_RELEASE} ${OPT_HELM_UNINSTALL}
# 	helm uninstall -n ${NAMESPACE} ${HELM_ISTIOD_RELEASE} ${OPT_HELM_UNINSTALL}
# 	helm uninstall -n ${NAMESPACE} ${HELM_GATEWAY_RELEASE} ${OPT_HELM_UNINSTALL}
# 	$(shell helm template ${HELM_BASE_CHART} -f ${HELM_BASE_VALUES} | yq 'select(.kind == "CustomResourceDefinition")' | kubeclt delete ${OPT_KUBECTL_DELETE} -f -)