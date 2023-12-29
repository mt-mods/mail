local function caps_ratio(str)
    local total_caps = 0
    for i = 1, #str do -- iteration through each character
        local c = str:sub(i,i)
        if string.lower(c) ~= c then -- do not count digits as spam
            total_caps = total_caps + 1
        end
    end
    return total_caps/(#str or 1) -- avoid division by zero
end

local function words_ratio(str, ratio)
    local words = {}
    local split_str = str:split(" ")
    for _, w in ipairs(split_str) do
        if not words[w] then
            words[w] = 0
        else
            words[w] = (words[w] or 0) + 1
        end
    end
    for _, n in pairs(words) do
        if n/#split_str >= ratio then
            return true
        end
    end
    return false
end

function mail.check_spam(message)
    local spam_checks = {}
    if caps_ratio(message.subject) == 1 or caps_ratio(message.body) > 0.4 then
        table.insert(spam_checks, "caps")
    end
    if words_ratio(message.subject, 0.6) or words_ratio(message.body, 0.2) then
        table.insert(spam_checks, "words")
    end
    return spam_checks
end
