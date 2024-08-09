#####################################
#          KIALI: Green          #
#####################################

# https://kiali.io/docs/installation/installation-guide/install-with-helm/
# https://istio.io/latest/docs/ops/integrations/kiali/
# https://istio.io/latest/docs/ops/integrations/prometheus/
# https://istio.io/latest/docs/ops/integrations/grafana/

KIALI_HOME := kiali
KIALI_PREFIX := kiali

ifneq (${ROOT_DIR}, $(abspath .))
$(error Location Error: Please Execute on Top-Level Directory (Current: $(shell pwd)))
endif

${KIALI_PREFIX}-%: NAMESPACE := kiali-operator
${KIALI_PREFIX}-%: HELM_RELEASE := kiali-operator
${KIALI_PREFIX}-%: HELM_CHART := kiali/kiali-operator
${KIALI_PREFIX}-%: HELM_CHART_VERSION := 1.88.0
${KIALI_PREFIX}-%: HELM_VALUES := ${KIALI_HOME}/values.yaml

${KIALI_PREFIX}-%: PATCH_ADDON_PROM := https://raw.githubusercontent.com/istio/istio/release-1.22/samples/addons/prometheus.yaml
${KIALI_PREFIX}-%: PATCH_ADDON_GRAF := https://raw.githubusercontent.com/istio/istio/release-1.22/samples/addons/grafana.yaml

${KIALI_PREFIX}-init:
	helm repo add kiali https://kiali.org/helm-charts
	helm show values ${HELM_CHART} --version ${HELM_CHART_VERSION} > $(shell echo ${HELM_VALUES} | sed -e 's/.yaml/.default.yaml/')
	touch ${HELM_VALUES}

${KIALI_PREFIX}-up:
	kubectl apply -f ${PATCH_ADDON_PROM} ${OPT_KUBECTL_APPLY}
	kubectl apply -f ${PATCH_ADDON_GRAF} ${OPT_KUBECTL_APPLY}
	helm upgrade -n ${NAMESPACE} ${HELM_RELEASE} ${HELM_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_VALUES} ${OPT_HELM_INSTALL}
	$(call print_url, https, kiali.geniouslab.io)

${KIALI_PREFIX}-down:
	kubectl delete kiali --all --all-namespaces ${OPT_KUBECTL_DELETE}
	helm uninstall -n ${NAMESPACE} ${HELM_RELEASE} ${OPT_HELM_UNINSTALL}
	kubectl delete crd kialis.kiali.io ${OPT_KUBECTL_DELETE}
	kubectl delete -f ${PATCH_ADDON_GRAF} ${OPT_KUBECTL_DELETE}
	kubectl delete -f ${PATCH_ADDON_PROM} ${OPT_KUBECTL_DELETE}
