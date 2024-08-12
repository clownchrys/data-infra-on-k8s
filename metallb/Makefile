#####################################
#          METAL-LB: Green          #
#####################################

# NOTE:
# cilium includes metallb-system, so that install this when you don't use it

METALLB := metallb
METALLB_HOME := metallb

ifneq ($(abspath ${K8S_PROJECT_DIR}), $(abspath .))
$(error Location Error: Please Execute on `K8S_PROJECT_DIR` (Current: $(shell pwd), K8S_PROJECT_DIR: ${K8S_PROJECT_DIR}))
endif

${METALLB}-%: NAMESPACE := metallb-system
${METALLB}-%: HELM_RELEASE := metallb
${METALLB}-%: HELM_CHART := metallb/metallb
${METALLB}-%: HELM_CHART_VERSION := 0.14.5
${METALLB}-%: HELM_VALUES := ${METALLB_HOME}/values.yaml

${METALLB}-%: PATCH_LB_IP_POOL := ${METALLB_HOME}/patches/lb-ipam.yaml
${METALLB}-%: PATCH_LB_L2_POLICY := ${METALLB_HOME}/patches/lb-l2-policy.yaml

${METALLB}-init:
	helm repo add metallb https://metallb.github.io/metallb
	helm show values ${HELM_CHART} --version ${HELM_CHART_VERSION} > $(shell echo ${HELM_VALUES} | sed -e 's/.yaml/.default.yaml/')
	touch ${HELM_VALUES}

${METALLB}-up:
	# kubectl get cm/kube-proxy -n kube-system -o yaml | sed -e "s/strictARP: false/strictARP: true/" | kubectl apply -n kube-system ${OPT_KUBECTL_APPLY} -f -
	helm upgrade -n ${NAMESPACE} ${HELM_RELEASE} ${HELM_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_VALUES} ${OPT_HELM_INSTALL}
	kubectl apply -n ${NAMESPACE} -f ${PATCH_LB_IP_POOL} ${OPT_KUBECTL_APPLY}
	kubectl apply -n ${NAMESPACE} -f ${PATCH_LB_L2_POLICY} ${OPT_KUBECTL_APPLY}

${METALLB}-down:
	helm uninstall -n ${NAMESPACE} ${HELM_RELEASE} ${OPT_HELM_UNINSTALL}
	kubectl delete -n ${NAMESPACE} -f ${PATCH_LB_IP_POOL} ${OPT_KUBECTL_DELETE}
	kubectl delete -n ${NAMESPACE} -f ${PATCH_LB_L2_POLICY} ${OPT_KUBECTL_DELETE}
