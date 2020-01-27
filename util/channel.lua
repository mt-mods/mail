-- bi-directional http-channel
-- with long-poll GET and POST on the same URL

local function Channel(http, url, cfg)
	cfg = cfg or {}
	local extra_headers = cfg.extra_headers or {}
	local timeout = cfg.timeout or 1
	local long_poll_timeout = cfg.long_poll_timeout or 30
	local error_retry = cfg.error_retry or 10

	-- assemble post-header with json content
	local post_headers = { "Content-Type: application/json" }
	for _,header in pairs(cfg.extra_headers) do
		table.insert(post_headers, header)
	end

	local recv_listeners = {}
	local run = true

	local recv_loop

	recv_loop = function()
		assert(run)

		-- long-poll GET
		http.fetch({
			url = url,
			extra_headers = extra_headers,
			timeout = long_poll_timeout
		}, function(res)
			if res.succeeded and res.code == 200 then
				local data = minetest.parse_json(res.data)

				if data then
					for _,listener in pairs(recv_listeners) do
						if #data > 0 then
							-- array received
							for _, entry in ipairs(data) do
								listener(entry)
							end
						else
							-- single item received
							listener(data)
						end
					end
				end
				-- reschedule immediately
				minetest.after(0, recv_loop)
			else
				-- error, retry after some time
				minetest.after(error_retry, recv_loop)
			end
		end)
	end


	local send = function(data)
		assert(run)
		-- POST

		http.fetch({
			url = url,
			extra_headers = post_headers,
			timeout = timeout,
			post_data = minetest.write_json(data)
		}, function()
			-- TODO: error-handling
		end)
	end

	local receive = function(listener)
		table.insert(recv_listeners, listener)
	end

	local close = function()
		run = false
	end

	recv_loop();

	return {
		send = send,
		receive = receive,
		close = close
	}

end



return Channel
