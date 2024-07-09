###################################
#          Cilium: Green          #
###################################

CILIUM := cilium
CILIUM_HOME := cilium

ifneq (${ROOT_DIR}, $(abspath .))
$(error Location Error: Please Execute on Top-Level Directory (Current: $(shell pwd)))
endif

${CILIUM}-%: NAMESPACE := kube-system
${CILIUM}-%: HELM_RELEASE := cilium
${CILIUM}-%: HELM_CHART := cilium/cilium
${CILIUM}-%: HELM_CHART_VERSION := 1.15.4
${CILIUM}-%: HELM_VALUES := ${CILIUM_HOME}/values.yaml

${CILIUM}-%: PATCH_LB_IP_POOL := ${CILIUM_HOME}/patches/lb-ipam.yaml
# ${CILIUM}-%: PATCH_LB_L2_POLICY := ${CILIUM_HOME}/patches/lb-l2-policy.yaml

${CILIUM}-init:
	helm repo add cilium https://helm.cilium.io/
	helm show values ${HELM_CHART} --version ${HELM_CHART_VERSION} > $(shell echo ${HELM_VALUES} | sed -e 's/.yaml/.default.yaml/')
	touch ${HELM_VALUES}

${CILIUM}-up:
	helm upgrade -n ${NAMESPACE} ${HELM_RELEASE} ${HELM_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_VALUES} ${OPT_HELM_INSTALL}
	kubectl apply -f ${PATCH_LB_IP_POOL} ${OPT_KUBECTL_APPLY}
	# kubectl apply -f ${PATCH_LB_L2_POLICY} ${OPT_KUBECTL_APPLY}

${CILIUM}-down:
	helm uninstall -n ${NAMESPACE} ${HELM_RELEASE} ${OPT_HELM_UNINSTALL}
	kubectl delete -f ${PATCH_LB_IP_POOL} ${OPT_KUBECTL_DELETE}
	# kubectl delete -f ${PATCH_LB_L2_POLICY} ${OPT_KUBECTL_DELETE}

${CILIUM}-hubble-up:
	helm upgrade -n ${NAMESPACE} ${HELM_RELEASE} ${HELM_CHART} --version ${HELM_CHART_VERSION} \
	--reuse-values \
	--set hubble.relay.enabled=true \
	--set hubble.ui.enabled=true \
	${OPT_HELM_INSTALL}
	$(call print_url, http, hubble.geniouslab.io)

${CILIUM}-hubble-down:
	helm upgrade -n ${NAMESPACE} ${HELM_RELEASE} ${HELM_CHART} --version ${HELM_CHART_VERSION} \
	--reuse-values \
	--set hubble.relay.enabled=false \
	--set hubble.ui.enabled=false \
	${OPT_HELM_INSTALL}
