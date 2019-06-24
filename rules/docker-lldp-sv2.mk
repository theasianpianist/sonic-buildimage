# docker image for lldp agent

DOCKER_LLDP_SV2 = docker-lldp-sv2.gz
$(DOCKER_LLDP_SV2)_PATH = $(DOCKERS_PATH)/docker-lldp-sv2
$(DOCKER_LLDP_SV2)_DEPENDS += $(LLDPD) $(LIBSWSSCOMMON) $(PYTHON_SWSSCOMMON)
$(DOCKER_LLDP_SV2)_PYTHON_WHEELS += $(DBSYNCD_PY2)
$(DOCKER_LLDP_SV2)_LOAD_DOCKERS += $(DOCKER_CONFIG_ENGINE_STRETCH)
SONIC_DOCKER_IMAGES += $(DOCKER_LLDP_SV2)
SONIC_INSTALL_DOCKER_IMAGES += $(DOCKER_LLDP_SV2)
SONIC_STRETCH_DOCKERS += $(DOCKER_LLDP_SV2)

$(DOCKER_LLDP_SV2)_CONTAINER_NAME = lldp
$(DOCKER_LLDP_SV2)_RUN_OPT += --privileged -t
$(DOCKER_LLDP_SV2)_RUN_OPT += -v /etc/sonic:/etc/sonic:ro

$(DOCKER_LLDP_SV2)_BASE_IMAGE_FILES += lldpctl:/usr/bin/lldpctl
