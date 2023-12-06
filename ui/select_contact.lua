-- translation
local S = minetest.get_translator("mail")

local FORMNAME = "mail:selectcontact"

local select_contact_formspec = "size[8,9;]" .. mail.theme .. [[
    tablecolumns[color;text;text]
    table[0,0;3.5,9;contacts;]] .. mail.get_color("header") .. "," .. S("Name") .. "," .. S("Note") .. [[%s]
    button[3.55,2.00;1.75,0.5;toadd;→ ]] .. S("Add") .. [[]
    button[3.55,2.75;1.75,0.5;toremove;← ]] .. S("Remove") .. [[]
    button[3.55,6.00;1.75,0.5;ccadd;→ ]] .. S("Add") .. [[]
    button[3.55,6.75;1.75,0.5;ccremove;← ]] .. S("Remove") .. [[]
    tablecolumns[color;text;text]
    table[5.15,0.0;2.75,4.5;to;]] .. mail.get_color("header") .. "," .. S("To") .. ":," .. S("Note") .. [[%s]
    tablecolumns[color;text;text]
    table[5.15,4.6;2.75,4.5;cc;]] .. mail.get_color("header") .. "," .. S("CC") .. ":," .. S("Note") .. [[%s]
    button[3.55,8.25;1.75,0.5;back;]] .. S("Back") .. [[]
]]


function mail.show_select_contact(name, to, cc)
	local formspec = select_contact_formspec
	local contacts = mail.compile_contact_list(name, mail.selected_idxs.contacts[name])

	-- compile lists
	if to then
		to = mail.compile_contact_list(name, mail.selected_idxs.to[name], to)
	else
		to = ""
	end
	if cc then
		cc = mail.compile_contact_list(name, mail.selected_idxs.cc[name], cc)
	else
		cc = ""
	end
	--[[if bcc then
		bcc = table.concat(mail.compile_contact_list(name, mail.selected_idxs.bcc[name], bcc)
	else
		bcc = ""
	end]]--
	formspec = string.format(formspec, contacts, to, cc)--, bcc()
	minetest.show_formspec(name, FORMNAME, formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= FORMNAME then
		return
	end

	local name = player:get_player_name()
	local contacts = mail.get_contacts(name)
	local draft = mail.message_drafts[name]

	-- get indexes for fields with selected rows
	-- execute their default button's actions if double clicked
	for k,action in pairs({
		contacts = "toadd",
		to = "toremove",
		cc = "ccremove",
		bcc = "bccremove"
	}) do
		if fields[k] then
			local evt = minetest.explode_table_event(fields[k])
			mail.selected_idxs[k][name] = evt.row - 1
			if evt.type == "DCL" and mail.selected_idxs[k][name] then
				fields[action] = true
			end
			return true
		end
	end

	local update = false
	-- add
	for _,v in pairs({"to","cc","bcc"}) do
		if fields[v.."add"] then
			update = true
			if mail.selected_idxs.contacts[name] then
				for k, contact, i in mail.pairsByKeys(contacts) do
					if k == mail.selected_idxs.contacts[name] or i == mail.selected_idxs.contacts[name] then
						local list = mail.parse_player_list(draft[v])
						list[#list+1] = contact.name
						mail.selected_idxs[v][name] = #list
						draft[v] = mail.concat_player_list(list)
						break
					end
				end
			end
		end
	end
	-- remove
	for _,v in pairs({"to","cc","bcc"}) do
		if fields[v.."remove"] then
			update = true
			if mail.selected_idxs[v][name] then
				local list = mail.parse_player_list(draft[v])
				table.remove(list, mail.selected_idxs[v][name])
				if #list < mail.selected_idxs[v][name] then
					mail.selected_idxs[v][name] = #list
				end
				draft[v] = mail.concat_player_list(list)
			end
		end
	end

	if update then
		mail.show_select_contact(name, draft.to, draft.cc, draft.bcc)
		return true
	end

	-- delete old idxs
	for _,v in ipairs({"contacts","to","cc","bcc"}) do
		mail.selected_idxs[v][name] = nil
	end

	mail.show_compose(name, draft.to, draft.subject, draft.body, draft.cc, draft.bcc)

	return true
end)
