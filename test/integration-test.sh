#!/bin/bash

MINETEST_VERSION=5.2.0

# prerequisites
jq --version || exit 1
curl --version || exit 1

# ensure proper current directory
CWD=$(dirname $0)
cd ${CWD}

# setup
unset use_proxy
unset http_proxy
unset https_proxy
unset HTTP_PROXY
unset HTTPS_PROXY

# run mail-server
docker pull minetestmail/mail
docker run --name mail --rm \
 -e WEBMAILKEY=myserverkey \
 -e WEBMAIL_DEBUG=true \
 --network host \
 minetestmail/mail &

# wait for startup
bash -c 'while !</dev/tcp/localhost/8080; do sleep 1; done;'

# start minetest with mail mod
docker pull registry.gitlab.com/minetest/minetest/server:${MINETEST_VERSION}
docker run --rm --name minetest \
  -u root:root \
	-v $(pwd)/minetest.conf:/etc/minetest/minetest.conf:ro \
  -v $(pwd)/world.mt:/root/.minetest/worlds/world/world.mt \
  -v $(pwd)/auth.sqlite:/root/.minetest/worlds/world/auth.sqlite \
  -v $(pwd)/../:/root/.minetest/worlds/world/worldmods/mail \
  -v $(pwd)/test_mod:/root/.minetest/worlds/world/worldmods/mail_test \
  -e use_proxy=false \
  -e http_proxy= \
  -e HTTP_PROXY= \
  --network host \
	registry.gitlab.com/minetest/minetest/server:${MINETEST_VERSION} &

# prepare cleanup
function cleanup {
	# cleanup
	docker stop mail
  docker stop minetest
}

trap cleanup EXIT

# wait for startup
sleep 5

# Execute calls against mail-server

# login
LOGIN_DATA='{"username":"test","password":"enter"}'
RES=$(curl --data "${LOGIN_DATA}" -H "Content-Type: application/json" "http://127.0.0.1:8080/api/login")
echo Login response: $RES
SUCCESS=$(echo $RES | jq -r .success)
TOKEN=$(echo $RES | jq -r .token)

# login succeeded
test "$SUCCESS" == "true" || exit 1
# token extracted
test -n "$TOKEN" || exit 1

# fetch mails
RES=$(curl -H "Authorization: ${TOKEN}" "http://127.0.0.1:8080/api/inbox")
echo Mailbox: ${RES}

# inbox count is 1
test "$(echo $RES | jq '. | length')" == "1" || exit 1

echo "Test complete!"
