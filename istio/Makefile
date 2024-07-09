##################################
#          ISTIO: Green          #
##################################

# https://istio.io/latest/docs/setup/install/helm/
# https://istio.io/latest/docs/setup/getting-started/#download

ISTIO := istio

ifneq (${ROOT_DIR}, $(abspath .))
$(error Location Error: Please Execute on Top-Level Directory (Current: $(shell pwd)))
endif

${ISTIO}-%: NAMESPACE := istio-system
${ISTIO}-%: HELM_CHART_VERSION := 1.16.0
${ISTIO}-%: HELM_BASE_RELEASE := istio-base
${ISTIO}-%: HELM_BASE_CHART := istio/base
${ISTIO}-%: HELM_BASE_VALUES := ${ISTIO}/values.base.yaml
${ISTIO}-%: HELM_ISTIOD_RELEASE := istio-istiod
${ISTIO}-%: HELM_ISTIOD_CHART := istio/istiod
${ISTIO}-%: HELM_ISTIOD_VALUES := ${ISTIO}/values.istiod.yaml
${ISTIO}-%: HELM_GATEWAY_RELEASE := istio-ingressgateway
${ISTIO}-%: HELM_GATEWAY_CHART := istio/gateway
${ISTIO}-%: HELM_GATEWAY_VALUES := ${ISTIO}/values.gateway.yaml

${ISTIO}-init:
	helm repo add istio https://istio-release.storage.googleapis.com/charts
	helm show values ${HELM_BASE_CHART} --version ${HELM_CHART_VERSION} > ./${ISTIO}/values.base.default.yaml
	helm show values ${HELM_ISTIOD_CHART} --version ${HELM_CHART_VERSION} > ./${ISTIO}/values.istiod.default.yaml
	helm show values ${HELM_GATEWAY_CHART} --version ${HELM_CHART_VERSION} > ./${ISTIO}/values.gateway.default.yaml
	touch ${HELM_BASE_VALUES}
	touch ${HELM_ISTIOD_VALUES}
	touch ${HELM_GATEWAY_VALUES}
	#cd ./${ISTIO} && curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${HELM_CHART_VERSION} TARGET_ARCH=x86_64 sh -

${ISTIO}-up:
	helm upgrade -n ${NAMESPACE} ${HELM_BASE_RELEASE} ${HELM_BASE_CHART} -f ${HELM_BASE_VALUES} --version ${HELM_CHART_VERSION} ${OPT_HELM_INSTALL}
	helm upgrade -n ${NAMESPACE} ${HELM_ISTIOD_RELEASE} ${HELM_ISTIOD_CHART} -f ${HELM_ISTIOD_VALUES} --version ${HELM_CHART_VERSION} ${OPT_HELM_INSTALL}
	helm upgrade -n ${NAMESPACE} ${HELM_GATEWAY_RELEASE} ${HELM_GATEWAY_CHART} -f ${HELM_GATEWAY_VALUES} --version ${HELM_CHART_VERSION} ${OPT_HELM_INSTALL}

${ISTIO}-down:
	helm uninstall -n ${NAMESPACE} ${HELM_BASE_RELEASE} ${OPT_HELM_UNINSTALL}
	helm uninstall -n ${NAMESPACE} ${HELM_ISTIOD_RELEASE} ${OPT_HELM_UNINSTALL}
	helm uninstall -n ${NAMESPACE} ${HELM_GATEWAY_RELEASE} ${OPT_HELM_UNINSTALL}
	$(shell helm template ${HELM_BASE_CHART} -f ${HELM_BASE_VALUES} | yq 'select(.kind == "CustomResourceDefinition")' | kubeclt delete ${OPT_KUBECTL_DELETE} -f -)

${ISTIO}-istio-ingressgateway-log:
	kubectl logs -n ${NAMESPACE} svc/istio-ingressgateway -f

${ISTIO}-envoy-proxy:
	kubectl port-forward -n ${NAMESPACE} deploy/istio-ingressgateway 15000:15000

${ISTIO}-usectl:
	$(eval ISTIOCTL := ./${ISTIO}/istio-${HELM_CHART_VERSION}/bin/istioctl)

${ISTIO}-usectl-test: ${ISTIO}-usectl
	$(ISTIOCTL) version
	#$(ISTIOCTL) install --set profile=default --skip-confirmation
