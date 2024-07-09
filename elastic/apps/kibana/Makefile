KIBANA := kibana
KIBANA_HOME := elastic/apps/kibana

ifneq (${ROOT_DIR}, $(abspath .))
$(error Location Error: Please Execute on Top-Level Directory (Current: $(shell pwd)))
endif

${KIBANA}-%: HELM_RELEASE := kibana
${KIBANA}-%: HELM_CHART := elastic/kibana
${KIBANA}-%: HELM_CHART_VERSION := 8.5.1
${KIBANA}-%: HELM_VALUES := ${KIBANA_HOME}/values.yaml

${KIBANA}-init: ${ELASTIC}-init
	helm repo add elastic https://helm.elastic.co
	helm show values ${HELM_CHART} --version ${HELM_CHART_VERSION} > $(shell echo ${HELM_VALUES} | sed -e 's/.yaml/.default.yaml/')
	touch ${HELM_VALUES}

${KIBANA}-up: ${ELASTIC}-up
	helm upgrade -n ${NAMESPACE} ${HELM_RELEASE} ${HELM_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_VALUES} ${OPT_HELM_INSTALL}
	$(call print_url, http, kibana.geniouslab.io)

${KIBANA}-down:
	kubectl delete -n ${NAMESPACE} secret kibana-kibana-es-token ${OPT_KUBECTL_DELETE}
	kubectl delete -n ${NAMESPACE} cm kibana-kibana-helm-scripts ${OPT_KUBECTL_DELETE}
	kubectl delete -n ${NAMESPACE} sa pre-install-kibana-kibana ${OPT_KUBECTL_DELETE}
	kubectl delete -n ${NAMESPACE} roles.rbac.authorization.k8s.io pre-install-kibana-kibana ${OPT_KUBECTL_DELETE}
	kubectl delete -n ${NAMESPACE} rolebindings.rbac.authorization.k8s.io pre-install-kibana-kibana ${OPT_KUBECTL_DELETE}
	kubectl delete -n ${NAMESPACE} jobs.batch pre-install-kibana-kibana ${OPT_KUBECTL_DELETE}
	kubectl delete -n ${NAMESPACE} sa post-delete-kibana-kibana ${OPT_KUBECTL_DELETE}
	kubectl delete -n ${NAMESPACE} roles.rbac.authorization.k8s.io post-delete-kibana-kibana ${OPT_KUBECTL_DELETE}
	kubectl delete -n ${NAMESPACE} rolebindings.rbac.authorization.k8s.io post-delete-kibana-kibana ${OPT_KUBECTL_DELETE}
	kubectl delete -n ${NAMESPACE} jobs.batch post-delete-kibana-kibana ${OPT_KUBECTL_DELETE}
	helm uninstall -n ${NAMESPACE} ${HELM_RELEASE} ${OPT_HELM_UNINSTALL}
