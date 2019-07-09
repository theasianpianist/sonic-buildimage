#!/bin/bash

function getMountPoint()
{
    echo $1 | python -c "import sys, json, os; mnts = [x for x in json.load(sys.stdin)[0]['Mounts'] if x['Destination'] == '/usr/share/sonic/hwsku']; print '' if len(mnts) == 0 else os.path.basename(mnts[0]['Source'])" 2>/dev/null
}

function getBootType()
{
    local BOOT_TYPE
    case "$(cat /proc/cmdline | grep -o 'SONIC_BOOT_TYPE=\S*' | cut -d'=' -f2)" in
    warm*)
        TYPE='warm'
        ;;
    fastfast)
        TYPE='fastfast'
        ;;
    fast*)
        TYPE='fast'
        ;;
    *)
        TYPE='cold'
    esac
    echo "${TYPE}"
}

function preStartAction()
{
    : # nothing
}

function postStartAction()
{
    : # nothing
}

start() {
	# Obtain boot type from kernel arguments
	BOOT_TYPE=`getBootType`

	# Obtain our platform as we will mount directories with these names in each docker
	PLATFORM=`sonic-cfggen -H -v DEVICE_METADATA.localhost.platform`
		# Obtain our HWSKU as we will mount directories with these names in each docker
		HWSKU=`sonic-cfggen -d -v 'DEVICE_METADATA["localhost"]["hwsku"]'`

	DOCKERCHECK=`docker inspect --type container $DEV 2>/dev/null`
	if [ "$?" -eq "0" ]; then
			DOCKERMOUNT=`getMountPoint "$DOCKERCHECK"`
		if [ x"$DOCKERMOUNT" == x"$HWSKU" ]; then
				echo "Starting existing $DEV container with HWSKU $HWSKU"
			preStartAction
			docker start $DEV
			postStartAction
			exit $?
		fi

		# docker created with a different HWSKU, remove and recreate
		echo "Removing obsolete $DEV container with HWSKU $DOCKERMOUNT"
		docker rm -f $DEV
	fi
		echo "Creating new $DEV container with HWSKU $HWSKU"
		docker create  \
		--log-opt max-size=2M --log-opt max-file=5 \
			-v /var/run/redis:/var/run/redis:rw \
			-v /usr/share/sonic/device/$PLATFORM:/usr/share/sonic/platform:ro \
			-v /usr/share/sonic/device/$PLATFORM/$HWSKU:/usr/share/sonic/hwsku:ro \
			--tmpfs /tmp \
			--tmpfs /var/tmp \
			--name= docker-namespace:latest || {
				echo "Failed to docker run" >&1
				exit 4
			}

	preStartAction
	docker start $DEV
	postStartAction
}

wait() {
    docker wait $DEV
}

stop() {
    docker stop $DEV
}

OP=$1
DEV=$2 # namespace/device number to operate on

if [ -z "$NUM_ASICS" ]; then
    export NUM_ASICS=6
fi

if [ -z "$NS_PREFIX" ]; then
    export NS_PREFIX="ns"
fi

case "$1" in
    start|wait|stop)
        $1
        ;;
    *)
        echo "Usage: $0 {start|wait|stop} {namespace}"
        exit 1
        ;;
esac
