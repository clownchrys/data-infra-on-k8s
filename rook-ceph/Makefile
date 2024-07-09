######################################
#          ROOK_CEPH: Green          #
######################################

ROOK_CEPH := rook-ceph

ifneq (${ROOT_DIR}, $(abspath .))
$(error Location Error: Please Execute on Top-Level Directory (Current: $(shell pwd)))
endif

${ROOK_CEPH}-%: NAMESPACE := rook-ceph
${ROOK_CEPH}-%: HELM_CHART_VERSION := 1.14.5

${ROOK_CEPH}-%: HELM_OPERATOR_RELEASE := rook-ceph
${ROOK_CEPH}-%: HELM_OPERATOR_CHART := rook-release/rook-ceph
${ROOK_CEPH}-%: HELM_OPERATOR_VALUES := ${ROOK_CEPH}/values.operator.yaml

${ROOK_CEPH}-%: HELM_CLUSTER_RELEASE := rook-ceph-cluster
${ROOK_CEPH}-%: HELM_CLUSTER_CHART := rook-release/rook-ceph-cluster
${ROOK_CEPH}-%: HELM_CLUSTER_VALUES := ${ROOK_CEPH}/values.cluster.yaml

${ROOK_CEPH}-init:
	@helm repo add rook-release https://charts.rook.io/release
	@helm show values ${HELM_OPERATOR_CHART} --version ${HELM_CHART_VERSION} > $(shell echo ${HELM_OPERATOR_VALUES} | sed -e 's/.yaml/.default.yaml/')
	@helm show values ${HELM_CLUSTER_CHART} --version ${HELM_CHART_VERSION} > $(shell echo ${HELM_CLUSTER_VALUES} | sed -e 's/.yaml/.default.yaml/')
	@touch ${HELM_OPERATOR_VALUES}
	@touch ${HELM_CLUSTER_VALUES}

${ROOK_CEPH}-up:
	helm upgrade -n ${NAMESPACE} ${HELM_OPERATOR_RELEASE} ${HELM_OPERATOR_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_OPERATOR_VALUES} ${OPT_HELM_INSTALL}
	helm upgrade -n ${NAMESPACE} ${HELM_CLUSTER_RELEASE} ${HELM_CLUSTER_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_CLUSTER_VALUES} ${OPT_HELM_INSTALL}

# https://rook.io/docs/rook/v1.11/Getting-Started/ceph-teardown/
# https://jay-chamber.tistory.com/entry/Rook-Ceph-Teardown-%EC%A0%95%EC%84%9D%EC%9C%BC%EB%A1%9C-%EC%88%98%ED%96%89%ED%95%98%EA%B8%B0
${ROOK_CEPH}-down:
	kubectl patch -n ${NAMESPACE} cephcluster/rook-ceph --type merge -p '{"spec":{"cleanupPolicy":{"confirmation":"yes-really-destroy-data"}}}'
	kubectl delete -n ${NAMESPACE} cephcluster/rook-ceph --wait=false
	helm uninstall -n ${NAMESPACE} ${HELM_CLUSTER_RELEASE} ${OPT_HELM_UNINSTALL}
	helm uninstall -n ${NAMESPACE} ${HELM_OPERATOR_RELEASE} ${OPT_HELM_UNINSTALL}
	kubectl api-resources -o name | grep 'rook.io' | xargs kubectl delete crd ${OPT_KUBECTL_DELETE}
	kubectl api-resources -o name | grep 'objectbucket.io' | xargs kubectl delete crd ${OPT_KUBECTL_DELETE}
ifeq (${CLUSTER_PROVIDER}, minikube)
	$(foreach node,$(shell kubectl get node -l node-role.kubernetes.io/worker= -o yaml | yq '.items[] | .metadata.name'),\
	minikube ssh -n ${node} 'sudo rm -rvf /var/lib/rook/${NAMESPACE}';)
else ifeq (${CLUSTER_PROVIDER}, k3s)
	${K3S_VAGRANT} ssh k3s-worker-1 -- sudo rm -rvf /var/lib/rook/${NAMESPACE}
	${K3S_VAGRANT} ssh k3s-worker-2 -- sudo rm -rvf /var/lib/rook/${NAMESPACE}
	${K3S_VAGRANT} ssh k3s-worker-3 -- sudo rm -rvf /var/lib/rook/${NAMESPACE}
endif

# ${ROOK_CEPH}-test: