#!/bin/sh

docker run --rm -it \
	-u root:root \
	-v $(pwd)/minetest.conf:/etc/minetest/minetest.conf \
	-v $(pwd)/players.sqlite:/root/.minetest/worlds/world/players.sqlite \
	-v $(pwd)/../:/root/.minetest/worlds/world/worldmods/mail_mod \
	-v mail_world:/root/.minetest/worlds/world/ \
	--network host \
	registry.gitlab.com/minetest/minetest/server:5.2.0
