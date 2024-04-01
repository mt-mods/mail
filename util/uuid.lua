-- source: https://gist.github.com/jrus/3197011
local random = math.random

function mail.search_box(playername, box, uuid)
	local e = mail.get_storage_entry(playername)
	for _, m in ipairs(e[box]) do
		if m.id == uuid then
		return { time = m.time, from = m.from, to = m.to, cc = m.cc, bcc = m.bcc, subject = m.subject, body = m.body } end
	end
	return false
end

function mail.is_uuid_existing(uuid)
    for _, k in ipairs(mail.storage:get_keys()) do
        if string.sub(k,1,5) == "mail/" then
			local p = string.sub(k, 6)
			local result
			local boxes = {"inbox", "outbox", "drafts", "trash"}
			for _, b in ipairs(boxes) do
				result = mail.search_box(p, b, uuid)
				if result then return result end
			end
		end
    end
    return false
end

function mail.are_message_sames(a, b)
	return a.time == b.time
	   and a.from == b.from
	   and a.to == b.to
	   and a.cc == b.cc
	   and a.bcc == b.bcc
	   and a.subject == b.subject
	   and a.body == b.body
end

function mail.new_uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    local candidate_uuid
    repeat
        candidate_uuid = string.gsub(template, '[xy]',
            function (c)
                local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
                return string.format('%x', v)
            end)
    until not mail.is_uuid_existing(candidate_uuid)
    return candidate_uuid
end
