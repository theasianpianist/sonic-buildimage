#!/bin/bash

for BACKEND in `seq 4 5`; do
	for FRONTEND in `seq 0 3`; do
		for LINK in `seq 0 4 28`; do
			BACK_NAME="Ethernet$(($FRONTEND*32+$LINK))"
			FRONT_OFFSET="$(($BACKEND-2))"
			FRONT_NAME="Ethernet$((32*$FRONT_OFFSET+$LINK))"
			
			until `sudo ip netns exec namespace$FRONTEND ip addr | grep --quiet "$FRONT_NAME"`; do
				sleep 1
			done			
			sudo ip netns exec namespace$FRONTEND ip addr add 10.$FRONTEND.$BACKEND.$(($LINK+1))/30 dev $FRONT_NAME

			until `sudo ip netns exec namespace$BACKEND ip addr | grep --quiet "$BACK_NAME"`; do
				sleep 1
			done
			sudo ip netns exec namespace$BACKEND ip addr add 10.$FRONTEND.$BACKEND.$(($LINK+2))/30 dev $BACK_NAME
		done
	done
done
