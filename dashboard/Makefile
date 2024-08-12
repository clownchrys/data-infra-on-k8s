######################################
#          DASHBOARD: Green          #
######################################

DASHBOARD := dashboard

ifneq ($(abspath ${K8S_PROJECT_DIR}), $(abspath .))
$(error Location Error: Please Execute on `K8S_PROJECT_DIR` (Current: $(shell pwd), K8S_PROJECT_DIR: ${K8S_PROJECT_DIR}))
endif

${DASHBOARD}-%: NAMESPACE := kubernetes-dashboard
${DASHBOARD}-%: HELM_RELEASE := kubernetes-dashboard
${DASHBOARD}-%: HELM_CHART := kubernetes-dashboard/kubernetes-dashboard
${DASHBOARD}-%: HELM_CHART_VERSION := 7.3.2
${DASHBOARD}-%: HELM_VALUES := ${DASHBOARD}/values.yaml

${DASHBOARD}-init:
	helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
	helm show values ${HELM_CHART} --version ${HELM_CHART_VERSION} > $(shell echo ${HELM_VALUES} | sed -e 's/.yaml/.default.yaml/')
	touch ${HELM_VALUES}

${DASHBOARD}-up:
	helm upgrade -n ${NAMESPACE} ${HELM_RELEASE} ${HELM_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_VALUES} ${OPT_HELM_INSTALL}
	$(call print_url, https, kubernetes-dashboard.geniouslab.io)
	$(MAKE) ${DASHBOARD}-account

${DASHBOARD}-down:
	helm uninstall -n ${NAMESPACE} ${HELM_RELEASE} ${OPT_HELM_UNINSTALL}

${DASHBOARD}-account: admin-token
