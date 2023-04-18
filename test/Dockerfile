ARG ENGINE_VERSION=5.7.0
FROM registry.gitlab.com/minetest/minetest/server:${ENGINE_VERSION}

# copy old v1 maildb for migration testing
COPY ./mail.db /root/.minetest/worlds/world/mail.db
# copy old v2 mail-dir and auth.sqlite for migration testing
COPY ./old_v2_player.json /root/.minetest/worlds/world/mails/
COPY ./auth.sqlite /root/.minetest/worlds/world/auth.sqlite

USER root
RUN apk add git &&\
    mkdir -p /root/.minetest/worlds/world/worldmods/ &&\
    git clone https://github.com/BuckarooBanzay/mtt /root/.minetest/worlds/world/worldmods/mtt

ENTRYPOINT minetestserver --config /minetest.conf