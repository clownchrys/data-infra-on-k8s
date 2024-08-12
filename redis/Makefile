##################################
#          REDIS: Green          #
##################################

REDIS := redis

ifneq ($(abspath ${K8S_PROJECT_DIR}), $(abspath .))
$(error Location Error: Please Execute on `K8S_PROJECT_DIR` (Current: $(shell pwd), K8S_PROJECT_DIR: ${K8S_PROJECT_DIR}))
endif

${REDIS}-%: NAMESPACE := redis
${REDIS}-%: HELM_RELEASE := redis
${REDIS}-%: HELM_CHART := bitnami/redis
${REDIS}-%: HELM_CHART_VERSION := 19.3.1
${REDIS}-%: HELM_VALUES := ${REDIS}/values.yaml

${REDIS}-init:
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm show values ${HELM_CHART} --version ${HELM_CHART_VERSION} > $(shell echo ${HELM_VALUES} | sed -e 's/.yaml/.default.yaml/')
	touch ${HELM_VALUES}

${REDIS}-up:
	helm upgrade -n ${NAMESPACE} ${HELM_RELEASE} ${HELM_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_VALUES} ${OPT_HELM_INSTALL}

${REDIS}-down:
	helm uninstall -n ${NAMESPACE} ${HELM_RELEASE} ${OPT_HELM_UNINSTALL}
