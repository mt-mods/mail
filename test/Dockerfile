ARG ENGINE_VERSION=5.5.0
FROM registry.gitlab.com/minetest/minetest/server:${ENGINE_VERSION}

USER root
RUN apk add git &&\
    mkdir -p /root/.minetest/worlds/world/worldmods/ &&\
    git clone https://github.com/BuckarooBanzay/mtt /root/.minetest/worlds/world/worldmods/mtt


ENTRYPOINT minetestserver --config /minetest.conf