######################################
#          MINIKUBE-CLUSTER          #
######################################

MINIKUBE := minikube
MINIKUBE_HOME := cluster/minikube

ifneq (${ROOT_DIR}, $(abspath .))
$(error Location Error: Please Execute on Top-Level Directory (Current: $(shell pwd)))
endif

define MINIKUBE_SYNC_INIT
[ -e ~/.minikube/files ] && { rm -rvf ~/.minikube/files && mkdir -p ~/.minikube/files }
endef

define MINIKUBE_SYNC
$(eval HOST_LOCATION = $(strip ${1}))
$(eval REMOTE_LOCATION = $(strip ${2}))
mkdir -pv $$(dirname ~/.minikube/files/${REMOTE_LOCATION})
cp -rvf ${HOST_LOCATION} ~/.minikube/files/${REMOTE_LOCATION}
endef

# --gpus = all | nvidia (for docker driver and docker cri)
# --feature-gates = '' (ex. 'EphemeralContainers=true,')
define MINIKUBE_COMMON
--driver=hyperkit \
--kubernetes-version=v1.29.2 \
--ha=false \
--nodes=4 \
--cpus=12 \
--memory=48gb \
--disk-size=100gb \
--gpus='' \
--feature-gates='' \
--install-addons=false \
--addons=default-storageclass,storage-provisioner \
--bootstrapper=kubeadm
endef

define MINIKUBE_MOUNT
--mount-gid='docker' \
--mount-uid='docker' \
--mount=true
endef

# --extra-config=kubelet.container-runtime-endpoint=unix://run/containerd/containerd.sock
# --extra-config=kubelet.image-service-endpoint=unix://run/containerd/containerd.sock
# --extra-config=kubelet.container-runtime=remote
define MINIKUBE_CONTAINER
--container-runtime=containerd
endef

# --cni = bridge (--enable-default-cni=false)
define MINIKUBE_NETWORK
--cni=bridge \
--apiserver-port=8443 \
--dns-domain=cluster.local \
--network=minikube
endef

# kubeadmConfigPatches:

# --extra-config='kubelet.eviction-minimum-reclaim=memory.available<0Mi,nodefs.available<500Mi,imagefs.available<2Gi'
# --extra-config=kubelet.eviction-minimum-reclaim.memory.available=0Mi \
# --extra-config=kubelet.eviction-minimum-reclaim.nodefs.available=500Mi \
# --extra-config=kubelet.eviction-minimum-reclaim.imagefs.available=2Gi \

# --extra-config=kubelet.eviction-pressure-transition-period=5m \
# --extra-config=kubelet.node-status-report-frequency=5m \
# --extra-config=kubelet.node-status-update-frequency=10s \
# --extra-config=kubelet.pods-per-core=0 \
# --extra-config=kubelet.pods-pids-limit=-1 \
# --extra-config=kubelet.max-pods=110

# --extra-config=kubelet.node-labels=created-by=minikube
# --extra-config='kubelet.eviction-hard.memory.available=100Mi'
define MINIKUBE_KUBEADM_CONFIG
--extra-config=$(subst $() $(),,'kubelet.eviction-hard= \
memory.available<100Mi, \
imagefs.available<15%, \
nodefs.available<10%, \
nodefs.inodesFree<5% \
')
endef

${MINIKUBE}-%: CLUSTER_NAME := minikube
${MINIKUBE}-%: PATCH_KUBE_ADMIN := ${MINIKUBE_HOME}/patches/kube-admin.yaml
${MINIKUBE}-%: PATCH_STORAGE_CLASS := ${MINIKUBE_HOME}/patches/storage-class.yaml
${MINIKUBE}-%: PATCH_STORAGE_PROVISIONER := ${MINIKUBE_HOME}/patches/storage-provisioner.yaml

# kubectl taint nodes --selector 'node-role.kubernetes.io/control-plane=' node-role.kubernetes.io/control-plane:NoSchedule- || echo 'Already disabled to taint: node-role.kubernetes.io/control-plane:NoSchedule'
# kubectl get nodes -l node-role.kubernetes.io/control-plane!= -o name --show-kind | xargs -I {} kubectl label {} node-role.kubernetes.io/worker=
${MINIKUBE}-up:
	$(call MINIKUBE_SYNC_INIT)
	$(call MINIKUBE_SYNC, ${MINIKUBE_HOME}/data, /data)
	$(call MINIKUBE_SYNC, ${MINIKUBE_HOME}/patches/containerd/certs.d, /etc/containerd/certs.d)
	$(call MINIKUBE_SYNC, ${MINIKUBE_HOME}/patches/containerd/config.toml, /etc/containerd/containerd.conf.d/minikube-host.toml)
	minikube start \
	--profile ${CLUSTER_NAME} \
	--alsologtostderr=false \
	--delete-on-failure=true \
	-v=7 \
	${MINIKUBE_COMMON} \
	${MINIKUBE_MOUNT} \
	${MINIKUBE_CONTAINER} \
	${MINIKUBE_NETWORK} \
	${MINIKUBE_KUBEADM_CONFIG} \
	;
	minikube status -o json | yq -P '.[] | select(.Worker == true) | .Name' | xargs -I {} kubectl label node/{} node-role.kubernetes.io/worker= --overwrite
	kubectl taint nodes node-role.kubernetes.io/control-plane:NoSchedule --selector='node-role.kubernetes.io/control-plane=' --overwrite
	kubectl apply -n kube-system -f ${PATCH_KUBE_ADMIN} ${OPT_KUBECTL_APPLY}
	kubectl apply -f ${PATCH_STORAGE_CLASS} ${OPT_KUBECTL_APPLY}
	kubectl apply -f ${PATCH_STORAGE_PROVISIONER} ${OPT_KUBECTL_APPLY}

${MINIKUBE}-down:
	# minikube stop --profile ${CLUSTER_NAME}
	minikube delete --profile ${CLUSTER_NAME}

${MINIKUBE}-freeze:
	minikube pause -A

${MINIKUBE}-melt:
	minikube unpause -A

${MINIKUBE}-log:
	minikube logs --file ${MINIKUBE}/.logfile
