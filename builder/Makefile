####################################
#          BUILDER: Green          #
####################################

BUILDER_ROOT := builder

ifneq ($(abspath ${K8S_PROJECT_DIR}), $(abspath .))
$(error Location Error: Please Execute on `K8S_PROJECT_DIR` (Current: $(shell pwd), K8S_PROJECT_DIR: ${K8S_PROJECT_DIR}))
endif

BUILDER_IMAGE := clownchrys/published:builder

.PHONY: builder
builder:
	docker build ./${BUILDER_ROOT} -f ./${BUILDER_ROOT}/Dockerfile -t ${BUILDER_IMAGE} --push