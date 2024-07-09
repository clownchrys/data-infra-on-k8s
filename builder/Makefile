####################################
#          BUILDER: Green          #
####################################

BUILDER_ROOT := builder

ifneq (${ROOT_DIR}, $(abspath .))
$(error Location Error: Please Execute on Top-Level Directory (Current: $(shell pwd)))
endif

BUILDER_IMAGE := clownchrys/published:builder

.PHONY: builder
builder:
	docker build ./${BUILDER_ROOT} -f ./${BUILDER_ROOT}/Dockerfile -t ${BUILDER_IMAGE} --push