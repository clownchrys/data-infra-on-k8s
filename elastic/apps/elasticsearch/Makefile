ELASTICSEARCH := elasticsearch
ELASTICSEARCH_HOME := elastic/apps/elasticsearch

ifneq (${ROOT_DIR}, $(abspath .))
$(error Location Error: Please Execute on Top-Level Directory (Current: $(shell pwd)))
endif

${ELASTICSEARCH}-%: HELM_RELEASE := elasticsearch
${ELASTICSEARCH}-%: HELM_CHART := elastic/elasticsearch
${ELASTICSEARCH}-%: HELM_CHART_VERSION := 8.5.1
${ELASTICSEARCH}-%: HELM_VALUES_MASTER := ${ELASTICSEARCH_HOME}/values.master.yaml
${ELASTICSEARCH}-%: HELM_VALUES_DATA := ${ELASTICSEARCH_HOME}/values.data.yaml

${ELASTICSEARCH}-init: ${ELASTIC}-init
	helm repo add elastic https://helm.elastic.co
	helm show values ${HELM_CHART} --version ${HELM_CHART_VERSION} > $(shell echo ${HELM_VALUES_MASTER} | sed -e 's/.yaml/.default.yaml/')
	helm show values ${HELM_CHART} --version ${HELM_CHART_VERSION} > $(shell echo ${HELM_VALUES_DATA} | sed -e 's/.yaml/.default.yaml/')
	touch ${HELM_VALUES_MASTER}
	touch ${HELM_VALUES_DATA}

${ELASTICSEARCH}-up: ${ELASTIC}-up
	helm upgrade -n ${NAMESPACE} ${HELM_RELEASE}-master ${HELM_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_VALUES_MASTER} ${OPT_HELM_INSTALL}
	helm upgrade -n ${NAMESPACE} ${HELM_RELEASE}-data ${HELM_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_VALUES_DATA} ${OPT_HELM_INSTALL}
	$(call print_url, https, elasticsearch.geniouslab.io)

# kubectl delete pv $(shell kubectl get pv -o yaml | yq 'del(.kind) | del(.metadata) | .items[] | select(.spec.claimRef.namespace == "${NAMESPACE}") | .metadata.name') ${OPT_KUBECTL_DELETE}
${ELASTICSEARCH}-down:
	helm uninstall -n ${NAMESPACE} ${HELM_RELEASE}-data ${OPT_HELM_UNINSTALL}
	helm uninstall -n ${NAMESPACE} ${HELM_RELEASE}-master ${OPT_HELM_UNINSTALL}
	kubectl get pvc -n ${NAMESPACE} -o name \
	| grep -E 'elasticsearch-(master|data)-elasticsearch-(master|data)-[0-9]+' \
	| xargs -I {} kubectl delete -n ${NAMESPACE} {} ${OPT_KUBECTL_DELETE}

${ELASTICSEARCH}-account:
	@echo Username: $$(kubectl get -n elastic secret elasticsearch-master-credentials -o yaml | yq '.data.username' | base64 -d)
	@echo Password: $$(kubectl get -n elastic secret elasticsearch-master-credentials -o yaml | yq '.data.password' | base64 -d)
