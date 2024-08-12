##################################
#          ISTIO: Green          #
##################################

# https://istio.io/latest/docs/setup/install/helm/
# https://istio.io/latest/docs/setup/getting-started/#download

ISTIO_HOME := istio
ISTIO_PREFIX := istio
ISTIO_VERSION := 1.22.0
ISTIO_TARGET_ARCH := x86_64

ISTIO := ${ISTIO_HOME}/installs/istio-${ISTIO_VERSION}

ifneq ($(abspath ${K8S_PROJECT_DIR}), $(abspath .))
$(error Location Error: Please Execute on `K8S_PROJECT_DIR` (Current: $(shell pwd), K8S_PROJECT_DIR: ${K8S_PROJECT_DIR}))
endif

${ISTIO_PREFIX}-%: REVISION := istio
${ISTIO_PREFIX}-%: CONFIG_YAML := ${ISTIO_HOME}/config.yaml

${ISTIO_PREFIX}-init:
	mkdir -p ${ISTIO_HOME}/installs
	cd ${ISTIO_HOME}/installs && curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${ISTIO_VERSION} TARGET_ARCH=${ISTIO_TARGET_ARCH} sh -
	${ISTIO}/bin/istioctl version

# https://istio.io/v1.22/docs/reference/commands/istioctl/
${ISTIO_PREFIX}-up:
	${ISTIO}/bin/istioctl install -f ${CONFIG_YAML} --skip-confirmation
${ISTIO_PREFIX}-down:
	${ISTIO}/bin/istioctl uninstall --skip-confirmation --purge

# https://istio.io/latest/docs/ops/integrations/prometheus/
${ISTIO_PREFIX}/prom-up:
	kubectl apply -f ${ISTIO}/samples/addons/prometheus.yaml ${OPT_KUBECTL_APPLY}
${ISTIO_PREFIX}/prom-down:
	kubectl delete -f ${ISTIO}/samples/addons/prometheus.yaml ${OPT_KUBECTL_DELETE}

# https://istio.io/latest/docs/ops/integrations/grafana/
${ISTIO_PREFIX}/grafana-up:
	kubectl apply -f ${ISTIO}/samples/addons/grafana.yaml ${OPT_KUBECTL_APPLY}
	kubectl apply -f ${ISTIO_HOME}/resources/ingress.grafana.yaml ${OPT_KUBECTL_APPLY}
	$(call print_url, https, grafana.geniouslab.io)
${ISTIO_PREFIX}/grafana-down:
	kubectl delete -f ${ISTIO_HOME}/resources/ingress.grafana.yaml ${OPT_KUBECTL_DELETE}
	kubectl delete -f ${ISTIO}/samples/addons/grafana.yaml ${OPT_KUBECTL_DELETE}

# https://istio.io/latest/docs/ops/integrations/kiali/
# https://istio.io/latest/docs/tasks/observability/kiali/
${ISTIO_PREFIX}/kiali-up:
	kubectl apply -f ${ISTIO}/samples/addons/kiali.yaml ${OPT_KUBECTL_APPLY}
	kubectl apply -f ${ISTIO_HOME}/resources/ingress.kiali.yaml ${OPT_KUBECTL_APPLY}
	$(call print_url, https, kiali.geniouslab.io)
${ISTIO_PREFIX}/kiali-down:
	kubectl delete -f ${ISTIO_HOME}/resources/ingress.kiali.yaml ${OPT_KUBECTL_DELETE}
	kubectl delete -f ${ISTIO}/samples/addons/kiali.yaml ${OPT_KUBECTL_DELETE}

# https://istio.io/latest/docs/examples/bookinfo/
# https://istio.io/latest/docs/examples/bookinfo/#determine-the-ingress-ip-and-port
${ISTIO_PREFIX}/bookinfo-up:
	kubectl apply -f ${ISTIO}/samples/bookinfo/platform/kube/bookinfo.yaml ${OPT_KUBECTL_APPLY}
	kubectl apply -f ${ISTIO}/samples/bookinfo/networking/bookinfo-gateway.yaml ${OPT_KUBECTL_APPLY}
${ISTIO_PREFIX}/bookinfo-down:
	kubectl down -f ${ISTIO}/samples/bookinfo/networking/bookinfo-gateway.yaml ${OPT_KUBECTL_DELETE}
	kubectl down -f ${ISTIO}/samples/bookinfo/platform/kube/bookinfo.yaml ${OPT_KUBECTL_DELETE}

${ISTIO_PREFIX}/istio-ingressgateway-log:
	kubectl logs -n istio-system svc/istio-ingressgateway -f



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
