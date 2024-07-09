FLUENT_BIT := fluent-bit
FLUENT_BIT_HOME := elastic/apps/fluent-bit

ifneq (${ROOT_DIR}, $(abspath .))
$(error Location Error: Please Execute on Top-Level Directory (Current: $(shell pwd)))
endif

${FLUENT_BIT}-%: HELM_RELEASE := fluent-bit
${FLUENT_BIT}-%: HELM_CHART := fluent/fluent-bit
${FLUENT_BIT}-%: HELM_CHART_VERSION := 0.46.9
${FLUENT_BIT}-%: HELM_VALUES := ${FLUENT_BIT_HOME}/values.yaml

${FLUENT_BIT}-init: ${ELASTIC}-init
	helm repo add fluent https://fluent.github.io/helm-charts
	helm show values ${HELM_CHART} --version ${HELM_CHART_VERSION} > $(shell echo ${HELM_VALUES} | sed -e 's/.yaml/.default.yaml/')
	touch ${HELM_VALUES}

${FLUENT_BIT}-up: ${ELASTIC}-up
	helm upgrade -n ${NAMESPACE} ${HELM_RELEASE} ${HELM_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_VALUES} ${OPT_HELM_INSTALL}

${FLUENT_BIT}-down:
	helm uninstall -n ${NAMESPACE} ${HELM_RELEASE} ${OPT_HELM_UNINSTALL}
