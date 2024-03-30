-- source: https://gist.github.com/jrus/3197011
local random = math.random

local function is_uuid_unexisting(uuid)
    for _, k in ipairs(mail.storage:get_keys()) do
        if string.sub(k,1,5) ~= "mail/" then
            goto continue
        end
        local p = string.sub(k, 6)
        local e = mail.get_storage_entry(p)
        for _, m in ipairs(e.inbox) do
            if m.id == uuid then return false end
        end
        for _, m in ipairs(e.outbox) do
            if m.id == uuid then return false end
        end
        for _, m in ipairs(e.drafts) do
            if m.id == uuid then return false end
        end
        for _, m in ipairs(e.trash) do
            if m.id == uuid then return false end
        end
        ::continue::
    end
    return true
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
    until is_uuid_unexisting(candidate_uuid)
    return candidate_uuid
end
