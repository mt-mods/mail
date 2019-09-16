#!/bin/sh

docker run --rm -it \
	-v $(pwd)/minetest.conf:/etc/minetest/minetest.conf \
	-v /tmp/mt:/var/lib/minetest/.minetest \
	-v $(pwd)/../:/var/lib/minetest/.minetest/worlds/world/worldmods/mail_mod \
	registry.gitlab.com/minetest/minetest/server:5.0.1
