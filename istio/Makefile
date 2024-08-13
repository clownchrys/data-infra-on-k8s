##################################
#          ISTIO: Green          #
##################################

# https://istio.io/latest/docs/setup/install/helm/
# https://istio.io/latest/docs/setup/getting-started/#download

ISTIO_HOME := istio
ISTIO_PREFIX := istio
ISTIO_VERSION := 1.22.3
ISTIO_TARGET_ARCH := x86_64

ISTIO_DOWNLOAD_DIR := ${HOME}/istio/versions/istio-${ISTIO_VERSION}
ISTIO_CURRENT_DIR := ${HOME}/istio/current

ifneq ($(abspath ${K8S_PROJECT_DIR}), $(abspath .))
$(error Location Error: Please Execute on `K8S_PROJECT_DIR` (Current: $(shell pwd), K8S_PROJECT_DIR: ${K8S_PROJECT_DIR}))
endif

# ${ISTIO_PREFIX}-%: REVISION := istio
${ISTIO_PREFIX}-%: CONFIG_YAML := ${ISTIO_HOME}/config.yaml

${ISTIO_PREFIX}-init:
	mkdir -p $$(dirname ${ISTIO_DOWNLOAD_DIR})
	cd $$(dirname ${ISTIO_DOWNLOAD_DIR}) && curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${ISTIO_VERSION} TARGET_ARCH=${ISTIO_TARGET_ARCH} sh -
	ln -sfnv ${ISTIO_DOWNLOAD_DIR} ${ISTIO_CURRENT_DIR}
	@echo "\nSet Environment Variable PATH:"
	@echo "\texport PATH=${ISTIO_CURRENT_DIR}/bin:\$$PATH\n"
	which istioctl
	istioctl version --remote=false

# https://istio.io/v1.22/docs/reference/commands/istioctl/
${ISTIO_PREFIX}-up:
	istioctl install -f ${CONFIG_YAML} --skip-confirmation
${ISTIO_PREFIX}-down:
	istioctl uninstall --skip-confirmation --purge

# https://istio.io/latest/docs/ops/integrations/prometheus/
${ISTIO_PREFIX}/prom-up:
	kubectl apply -f ${ISTIO_CURRENT_DIR}/samples/addons/prometheus.yaml ${OPT_KUBECTL_APPLY}
${ISTIO_PREFIX}/prom-down:
	kubectl delete -f ${ISTIO_CURRENT_DIR}/samples/addons/prometheus.yaml ${OPT_KUBECTL_DELETE}

# https://istio.io/latest/docs/ops/integrations/grafana/
${ISTIO_PREFIX}/grafana-up:
	kubectl apply -f ${ISTIO_CURRENT_DIR}/samples/addons/grafana.yaml ${OPT_KUBECTL_APPLY}
	kubectl apply -f ${ISTIO_HOME}/resources/ingress.grafana.yaml ${OPT_KUBECTL_APPLY}
	$(call print_url, https, grafana.geniouslab.io)
${ISTIO_PREFIX}/grafana-down:
	kubectl delete -f ${ISTIO_HOME}/resources/ingress.grafana.yaml ${OPT_KUBECTL_DELETE}
	kubectl delete -f ${ISTIO_CURRENT_DIR}/samples/addons/grafana.yaml ${OPT_KUBECTL_DELETE}

# https://istio.io/latest/docs/ops/integrations/kiali/
# https://istio.io/latest/docs/tasks/observability/kiali/
${ISTIO_PREFIX}/kiali-up:
	kubectl apply -f ${ISTIO_CURRENT_DIR}/samples/addons/kiali.yaml ${OPT_KUBECTL_APPLY}
	kubectl apply -f ${ISTIO_HOME}/resources/ingress.kiali.yaml ${OPT_KUBECTL_APPLY}
	$(call print_url, https, kiali.geniouslab.io)
${ISTIO_PREFIX}/kiali-down:
	kubectl delete -f ${ISTIO_HOME}/resources/ingress.kiali.yaml ${OPT_KUBECTL_DELETE}
	kubectl delete -f ${ISTIO_CURRENT_DIR}/samples/addons/kiali.yaml ${OPT_KUBECTL_DELETE}

# https://istio.io/latest/docs/examples/bookinfo/
# https://istio.io/latest/docs/examples/bookinfo/#determine-the-ingress-ip-and-port
${ISTIO_PREFIX}/bookinfo-up:
	kubectl apply -f ${ISTIO_CURRENT_DIR}/samples/bookinfo/platform/kube/bookinfo.yaml ${OPT_KUBECTL_APPLY}
	kubectl apply -f ${ISTIO_CURRENT_DIR}/samples/bookinfo/networking/bookinfo-gateway.yaml ${OPT_KUBECTL_APPLY}
${ISTIO_PREFIX}/bookinfo-down:
	kubectl down -f ${ISTIO_CURRENT_DIR}/samples/bookinfo/networking/bookinfo-gateway.yaml ${OPT_KUBECTL_DELETE}
	kubectl down -f ${ISTIO_CURRENT_DIR}/samples/bookinfo/platform/kube/bookinfo.yaml ${OPT_KUBECTL_DELETE}

${ISTIO_PREFIX}/istio-ingressgateway-log:
	kubectl logs -n istio-system svc/istio-ingressgateway -f
