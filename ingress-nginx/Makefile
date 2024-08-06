####################################
#          INGRESS: Green          #
####################################

INGRESS_NGINX := ingress-nginx

ifneq (${ROOT_DIR}, $(abspath .))
$(error Location Error: Please Execute on Top-Level Directory (Current: $(shell pwd)))
endif

${INGRESS_NGINX}-%: NAMESPACE := ingress-nginx
${INGRESS_NGINX}-%: HELM_RELEASE := ingress-nginx
${INGRESS_NGINX}-%: HELM_CHART := ingress-nginx/ingress-nginx
${INGRESS_NGINX}-%: HELM_CHART_VERSION := 4.10.0
${INGRESS_NGINX}-%: HELM_VALUES := ${INGRESS_NGINX}/values.yaml

${INGRESS_NGINX}-init:
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm show values ${HELM_CHART} --version ${HELM_CHART_VERSION} > $(shell echo ${HELM_VALUES} | sed -e 's/.yaml/.default.yaml/')
	touch ${HELM_VALUES}

${INGRESS_NGINX}-up:
ifeq (${CLUSTER_PROVIDER}, minikube)
	kubectl label nodes minikube-m02 node-role.kubernetes.io/ingress=true --overwrite
else ifeq (${CLUSTER_PROVIDER}, kind)
	kubectl label nodes kind-worker2 node-role.kubernetes.io/ingress=true --overwrite
else ifeq (${CLUSTER_PROVIDER}, k3s)
	kubectl label nodes k3s-worker-1 node-role.kubernetes.io/ingress=true --overwrite
endif
	helm upgrade -n ${NAMESPACE} ${HELM_RELEASE} ${HELM_CHART} --version ${HELM_CHART_VERSION} -f ${HELM_VALUES} ${OPT_HELM_INSTALL}

${INGRESS_NGINX}-down:
	helm uninstall -n ${NAMESPACE} ${HELM_RELEASE} ${OPT_HELM_UNINSTALL}

${INGRESS_NGINX}-log:
	kubectl logs -n ${NAMESPACE} deploy/ingress-nginx-controller -f

${INGRESS_NGINX}-connect:
	kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller --address 0.0.0.0 80:80 443:443
