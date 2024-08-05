SHELL := /bin/zsh
ROOT_DIR := /Users/imgeunchan/tmp/data-infra-on-k8s

############################
#          COMMON          #
############################

define OPT_HELM_INSTALL
--install \
--create-namespace \
--wait \
--wait-for-jobs \
--timeout 1h0m0s \
--cleanup-on-fail \
--debug
endef

define OPT_HELM_UNINSTALL
--wait \
--ignore-not-found \
--cascade background \
--timeout 1h0m0s
endef

define OPT_KUBECTL_APPLY
--wait
endef

define OPT_KUBECTL_DELETE
--force \
--ignore-not-found
endef

##############################
#          FUNCTION          #
##############################

define print_url
$(eval SCHEME = ${1})
$(eval HOSTNAME = ${2})

@echo "\n[SYSTEM] URL:\n"
@echo "\t${SCHEME}://${HOSTNAME}\n"
@cat /etc/hosts | grep ${HOSTNAME} 1> /dev/null 2>&1 \
&& echo "ingress hostname already exists in /etc/hosts" \
|| echo "***** Execute Following Command *****\n\necho '0.0.0.0 ${HOSTNAME}' | sudo tee -a /etc/hosts"
endef

define create_ns
@kubectl create ns ${1} --dry-run=server \
&& kubectl create ns ${1} \
|| echo Namespace '${1}' already exists!
endef

define upper_str
$(1) := $$(shell echo $1 | tr '[:lower:]' '[:upper:]')
endef

define no_whitespace
$(subst $() $(),,${1})
endef

__check_defined__ = $(if $(value $1),, $(error Undefined `$1`$(if $2,: $2)$(if $(value @), (Required By Target: `$@`))))
check_defined = $(strip $(foreach 1,$1, $(call __check_defined__,$1,$(strip $(value 2)))))
check-defined-%:
	$(call check_defined, $*, target-specific)

#############################
#          UTILITY          #
#############################

admin-token:
	@echo "\n[SYSTEM] Bearer token for 'kube-admin':\n"
	kubectl create token kube-admin -n kube-system

list-pods:
	kubectl get pods \
	-o custom-columns="POD:metadata.name,STATUS:status.phase,STATE:status.containerStatuses[*].state.waiting.reason" \
	-A

watch-running:
	watch -n 1 kubectl get po -o wide --field-selector status.phase==Running ${ns}

watch-not-running:
	watch -n 1 kubectl get po -o wide --field-selector status.phase!=Running ${ns}

bash-shell:
	kubectl exec -n ${ns} -it ${dest} -- bash

# --copy-to=${pod}-debug
# kubectl delete -n ${ns} po/${pod}-debug ${OPT_KUBECTL_DELETE}
debug-shell:
	$(call check_defined, ns pod image)
	kubectl debug -n ${ns} -it ${pod} --image=${image} --share-processes -- /bin/sh

# WARNING: NOT RECOMMENDED!!
# kubectl get ns ${namespace} -o json \
# | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/"
kill-hang-force:
	kubectl get ns ${namespace} -o json | jq '.spec.finalizers=[]' \
	| kubectl replace --raw /api/v1/namespaces/${namespace}/finalize -f -

# NOTE: BETTER WORKS :)
ns-resources:
	kubectl api-resources --verbs=list --namespaced -o name \
	| xargs -n 1 kubectl get -o name --show-kind --ignore-not-found -n ${namespace}

%-restart: %-down %-up
	@#line must be required on target-dependency working (make $*-restart)

#############################
#          CLUSTER          #
#############################

include cluster/kind/Makefile
include cluster/minikube/Makefile
include cluster/k3s/Makefile

CLUSTER_PROVIDER := k3s

cluster-info:
	@echo Current: ${CLUSTER_PROVIDER}
cluster-up: ${CLUSTER_PROVIDER}-up
cluster-down: ${CLUSTER_PROVIDER}-down
cluster-freeze: ${CLUSTER_PROVIDER}-freeze
cluster-melt: ${CLUSTER_PROVIDER}-melt

##################################
#          APPLICATIONS          #
##################################

include builder/Makefile

include cilium/Makefile
include metallb/Makefile
include ingress-nginx/Makefile
include dashboard/Makefile
include kubeview/Makefile
include airflow/Makefile
include gitlab/Makefile
include argocd/Makefile
include argocd-image-updater/Makefile
include jenkins/Makefile
include ray/Makefile
include kubeflow/Makefile
include mlflow/Makefile
include feast/Makefile
include postgresql/Makefile
include minio/Makefile
include redis/Makefile
include reflector/Makefile
include cert-manager/Makefile
include istio/Makefile
include harbor/Makefile
include keycloak/Makefile
include elastic/Makefile
include metrics-server/Makefile
include rook-ceph/Makefile
include rancher/Makefile
include mlrun/Makefile

#############################
#          ALIASES          #
#############################

done:

up: \
	cluster-up \
	core-up \
	storage-up \
	management-up \
	monitoring-up \
	application-up \
	done
# \
#
down: cluster-down
restart: down up

core-up: \
	cilium-up \
	ingress-nginx-up \
	cert-manager-up \
	istio-up \
	reflector-up \
	keycloak-up \
	done
# \
	metrics-server-up \
#

datastore-up: \
	postgresql-up \
	minio-up \
	redis-up \
	done
# \
	rook-ceph-up \
#

management-up: \
	done
# \
#

monitoring-up: \
	kubeview-up \
	cilium-hubble-up \
	dashboard-up \
	done
# \
#

application-up: \
	gitlab-up \
	argocd-up \
	mlflow-up \
	kubeflow-up \
	done
# \
	airflow-up \
	elastic-elasticsearch-up \
	elastic-fluent-bit-up \
	elastic-kibana-up \
	argocd-image-updater-up \
#

################################
#          DEPRECATED          #
################################

list-port-forward:
	@echo "PID\tPORT\tSERVICE"
	ps -ef | grep 'kubectl' | grep 'port-forward' | awk '{split($$13,ports,":"); print $$2 "\t" ports[1] "\t" $$12 " " $$9 " " $$10}' | grep svc

example:
	@echo https://k8s.io/examples/application/deployment.yaml