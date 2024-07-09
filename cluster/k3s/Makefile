#################################
#          K3S-CLUSTER          #
#################################

# REQUIRED
# vagrant plugin install vagrant-hosts

# REF
# vagrant plugin install vagrant-scp
# vagrant plugin install vagrant-vbguest
# vagrant plugin install vagrant-k3s  # https://github.com/k3s-io/vagrant-k3s


K3S := k3s
K3S_HOME := cluster/k3s
# K3S_VERSION := v1.29.2
K3S_VERSION := v1.28.10
K3S_VAGRANT := cd ${K3S_HOME} && vagrant

ifneq (${ROOT_DIR}, $(abspath .))
$(error Location Error: Please Execute on Top-Level Directory (Current: $(shell pwd)))
endif

${K3S}-%: K3S_VAGRANT := cd ${K3S_HOME} && vagrant

${K3S}-kube-config:
	${K3S_VAGRANT} ssh k3s-master-1 -- sudo cat /etc/rancher/k3s/k3s.yaml > data/k3s.yaml
	sed -i '' "s/default/k3s/g" ${K3S_HOME}/data/k3s.yaml
	yq -i '.current-context="k3s"' ${K3S_HOME}/data/k3s.yaml
	KUBECONFIG=${K3S_HOME}/data/k3s.yaml:~/.kube/config kubectl config view --raw > ~/.kube/config.tmp
	mv -fv ~/.kube/config.tmp ~/.kube/config
	chmod 600 ~/.kube/config

${K3S}-init:
	mkdir -p ${K3S_HOME}/patches/bin/${K3S_VERSION}
	if test -f ${K3S_HOME}/patches/bin/${K3S_VERSION}/k3s; then rm -rvf ${K3S_HOME}/patches/bin/${K3S_VERSION}/k3s; fi
	wget https://github.com/k3s-io/k3s/releases/download/${K3S_VERSION}+k3s1/k3s \
		--output-document=${K3S_HOME}/patches/bin/${K3S_VERSION}/k3s \
		--no-clobber
	chmod +x ${K3S_HOME}/patches/bin/${K3S_VERSION}/k3s

${K3S}-up:
	${K3S_VAGRANT} up
	$(MAKE) ${K3S}-kube-config

${K3S}-down:
	${K3S_VAGRANT} halt -f
	${K3S_VAGRANT} destroy -f --no-parallel

${K3S}-freeze:
	${K3S_VAGRANT} suspend

${K3S}-melt:
	${K3S_VAGRANT} resume

${K3S}-reload:
	${K3S_VAGRANT} reload --no-provision

${K3S}-status:
	${K3S_VAGRANT} status

${K3S}-shell:
	${K3S_VAGRANT} ssh ${node}