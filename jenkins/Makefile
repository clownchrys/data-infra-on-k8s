##################################
#          JENKINS: Red          #
##################################

JENKINS := jenkins

ifneq ($(abspath ${K8S_PROJECT_DIR}), $(abspath .))
$(error Location Error: Please Execute on `K8S_PROJECT_DIR` (Current: $(shell pwd), K8S_PROJECT_DIR: ${K8S_PROJECT_DIR}))
endif

${JENKINS}-%: NAMESPACE := jenkins
${JENKINS}-%: HELM_RELEASE := jenkins
${JENKINS}-%: HELM_CHART := jenkins/jenkins
${JENKINS}-%: HELM_CHART_VERSION := 5.1.6
${JENKINS}-%: HELM_VALUES := ${JENKINS}/values.yaml

${JENKINS}-init:
	helm repo add jenkins https://charts.jenkins.io/
	helm show values ${HELM_CHART} --version ${HELM_CHART_VERSION} > $(shell echo ${HELM_VALUES} | sed -e 's/.yaml/.default.yaml/')
	touch ${HELM_VALUES}

${JENKINS}-up:
	helm upgrade -n ${NAMESPACE} ${HELM_RELEASE} ${HELM_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_VALUES} ${OPT_HELM_INSTALL}
	$(call print_url, http, jenkins.geniouslab.io)

${JENKINS}-down:
	helm uninstall -n ${NAMESPACE} ${HELM_RELEASE} ${OPT_HELM_UNINSTALL}
