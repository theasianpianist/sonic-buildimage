#!/usr/bin/env python

#############################################################################
# Celestica
#
# Component contains an implementation of SONiC Platform Base API and
# provides the components firmware management function
#
#############################################################################

import json
import os.path
import shutil
import shlex
import subprocess

try:
    from sonic_platform_base.device_base import DeviceBase
except ImportError as e:
    raise ImportError(str(e) + "- required module not found")

MMC_CPLD_ADDR = '0x100'
BIOS_VERSION_PATH = "/sys/class/dmi/id/bios_version"
CONFIG_DB_PATH = "/etc/sonic/config_db.json"
SMC_CPLD_PATH = "/sys/devices/platform/e1031.smc/version"
MMC_CPLD_PATH = "/sys/devices/platform/e1031.smc/getreg"


class Component(DeviceBase):
    """Platform-specific Component class"""

    DEVICE_TYPE = "component"

    def __init__(self, component_name):
        DeviceBase.__init__(self)
        self.name = component_name.upper()

    def __run_command(self, command):
        # Run bash command and print output to stdout
        try:
            process = subprocess.Popen(
                shlex.split(command), stdout=subprocess.PIPE)
            while True:
                output = process.stdout.readline()
                if output == '' and process.poll() is not None:
                    break
            rc = process.poll()
            if rc != 0:
                return False
        except:
            return False
        return True

    def __get_register_value(self, path, register):
        # Retrieves the cpld register value
        cmd = "echo {1} > {0}; cat {0}".format(path, register)
        p = subprocess.Popen(
            cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        raw_data, err = p.communicate()
        if err is not '':
            return None
        return raw_data.strip()

    def __get_bios_version(self):
        # Retrieves the BIOS firmware version
        try:
            with open(BIOS_VERSION_PATH, 'r') as fd:
                bios_version = fd.read()
                return bios_version.strip()
        except Exception as e:
            return None

    def __get_cpld_version(self):
        # Retrieves the CPLD firmware version
        cpld_version = dict()
        with open(SMC_CPLD_PATH, 'r') as fd:
            smc_cpld_version = fd.read()
        smc_cpld_version = 'None' if smc_cpld_version is 'None' else "{}.{}".format(
            int(smc_cpld_version[2], 16), int(smc_cpld_version[3], 16))

        mmc_cpld_version = self.__get_register_value(
            MMC_CPLD_PATH, MMC_CPLD_ADDR)
        mmc_cpld_version = 'None' if mmc_cpld_version is 'None' else "{}.{}".format(
            int(mmc_cpld_version[2], 16), int(mmc_cpld_version[3], 16))

        cpld_version["SMC_CPLD"] = smc_cpld_version
        cpld_version["MMC_CPLD"] = mmc_cpld_version
        return cpld_version

    def get_firmware_version(self):
        """
        Retrieves the firmware version of module
        Returns:
            string: The firmware versions of the module
        """
        fw_version = None

        if self.name == "BIOS":
            fw_version = self.__get_bios_version()
        elif "CPLD" in self.name:
            cpld_version = self.__get_cpld_version()
            fw_version = cpld_version.get(self.name)

        return fw_version

    def upgrade_firmware(self, image_path):
        """
        Install firmware to module
        Args:
            image_path: A string, path to firmware image
        Returns:
            A boolean, True if install successfully, False if not
        """
        if not os.path.isfile(image_path):
            return False

        if "CPLD" in self.name:
            img_name = os.path.basename(image_path)
            root, ext = os.path.splitext(img_name)
            ext = ".vme" if ext == "" else ext
            new_image_path = os.path.join("/tmp", (root.lower() + ext))
            shutil.copy(image_path, new_image_path)
            install_command = "ispvm %s" % new_image_path
        elif self.name == "BIOS":
            print("Not supported")
            return False

        return self.__run_command(install_command)
