###########################################
#          METRICS-SERVER: Green          #
###########################################

METRICS_SERVER := metrics-server

ifneq ($(abspath ${K8S_PROJECT_DIR}), $(abspath .))
$(error Location Error: Please Execute on `K8S_PROJECT_DIR` (Current: $(shell pwd), K8S_PROJECT_DIR: ${K8S_PROJECT_DIR}))
endif

${METRICS_SERVER}-%: NAMESPACE := kube-system
${METRICS_SERVER}-%: HELM_RELEASE := metrics-server
${METRICS_SERVER}-%: HELM_CHART := metrics-server/metrics-server
${METRICS_SERVER}-%: HELM_CHART_VERSION := 3.12.1
${METRICS_SERVER}-%: HELM_VALUES := ${METRICS_SERVER}/values.yaml

${METRICS_SERVER}-init:
	@helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server
	@helm show values ${HELM_CHART} --version ${HELM_CHART_VERSION} > $(shell echo ${HELM_VALUES} | sed -e 's/.yaml/.default.yaml/')
	@touch ${HELM_VALUES}

${METRICS_SERVER}-up:
	@helm upgrade -n ${NAMESPACE} ${HELM_RELEASE} ${HELM_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_VALUES} ${OPT_HELM_INSTALL}

${METRICS_SERVER}-down:
	@helm uninstall -n ${NAMESPACE} ${HELM_RELEASE} ${OPT_HELM_UNINSTALL}
