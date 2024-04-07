-- translation
local S = minetest.get_translator("mail")

local FORMNAME = "mail:settings"

local function get_settings_groups(parent)
    -- generate ordered list of settings
    local groups = {}
    for _, g in ipairs(mail.settings_groups) do
        if (g.parent or 0) == parent then
            table.insert(groups, g)
            -- insert sub groups just after the parent group
            table.insert_all(groups, get_settings_groups(g.name))
        end
    end
    return groups
end

local groups_labels = {}
local ordered_groups = get_settings_groups(0)
local tree_indent = 0
for i, g in ipairs(ordered_groups) do
    if not g.parent then tree_indent = 0
    elseif i > 1 and g.parent == ordered_groups[i-1].name then tree_indent = tree_indent + 1
    elseif i > 1 and g.parent ~= ordered_groups[i-1].parent then tree_indent = tree_indent - 1
    end
    table.insert(groups_labels, tostring(tree_indent))
    table.insert(groups_labels, g.label)
end
local groups_str = table.concat(groups_labels, ",")

function mail.show_settings(name)
    local group_index = 1
    mail.selected_idxs.settings_group[name] = mail.selected_idxs.settings_group[name] or mail.settings_groups[1].name

    for i, g in ipairs(ordered_groups) do
        if g.name == mail.selected_idxs.settings_group[name] then
            group_index = i
            break
        end
    end

	local formspec = [[
			size[10,6;]
			tabheader[0,0;optionstab;]] .. S("Settings") .. "," .. S("About") .. [[;1;false;false]
			button[9.35,0;0.75,0.5;back;X]

			tablecolumns[tree;text]
            table[0,0.775;3,4.5;groups;]] .. groups_str .. [[;]] .. group_index .. [[]

			box[0,0;3,0.45;]] .. mail.get_color("highlighted") .. [[]
			label[0.2,0;]] .. mail.settings_groups[group_index].label .. [[]

            button[0,5.65;2.5,0.5;reset;]] .. S("Reset") .. [[]
            button[7.5,5.65;2.5,0.5;save;]] .. S("Save") .. [[]
            ]]

    local x = 3.5
    local y = -0.7
    -- put settings in order
    local ordered_settings = {}
    for setting, data in pairs(mail.settings) do
        if data.group == mail.selected_idxs.settings_group[name] then
            table.insert(ordered_settings, setting)
        end
    end
    table.sort(ordered_settings, function(a, b) return mail.settings[a].index < mail.settings[b].index end)
    for _, setting in pairs(ordered_settings) do
        local data = mail.settings[setting]
        y = y + 0.4
        local field_default = mail.selected_idxs[setting][name]
        if field_default == nil then field_default = mail.get_setting(name, setting) end
        if data.type == "bool" then
            formspec = formspec .. [[
            checkbox[]] .. x .. "," .. y .. ";" .. setting .. ";" ..
            data.label .. ";" .. tostring(field_default) .. [[]
            ]]
            if data.tooltip then
                formspec = formspec .. [[
                tooltip[]] .. setting .. ";" .. data.tooltip .. [[]
                ]]
            end
        elseif data.type == "string" then
            y = y + 1
            formspec = formspec .. [[
            field[]] .. x+0.275 .. "," .. y .. ";3,0.5;" .. setting .. ";" .. data.label .. [[;]] ..
            field_default .. [[]
            ]]
            if data.tooltip then
                formspec = formspec .. "tooltip[" .. setting .. ";" .. data.tooltip .. "]"
            end
            if data.dataset then
                local formatted_dataset = table.copy(data.dataset)
                if data.format then
                    for i, d in ipairs(formatted_dataset) do
                        formatted_dataset[i] = data.format(d)
                    end
                end
                local dataset_str = table.concat(formatted_dataset, ",")
                local dataset_selected_id = 1
                for i, d in ipairs(data.dataset) do
                    if d == field_default then
                        dataset_selected_id = i
                        break
                    end
                end
                formspec = formspec .. [[
                dropdown[]] .. x+3 .. "," .. y-0.45 .. ";3,0.5;" .. "dataset_" .. setting .. ";" ..
                dataset_str .. [[;]] .. dataset_selected_id .. [[;true]
                ]]
            end

        elseif data.type == "index" then
            y = y + 0.2
            local formatted_dataset = table.copy(data.dataset)
            if data.format then
                for i, d in ipairs(formatted_dataset) do
                    formatted_dataset[i] = data.format(d)
                end
            end
            local dataset_str = table.concat(formatted_dataset, ",")
            local dataset_selected_id = field_default
            formspec = formspec .. [[
            label[]] .. x .. "," .. y .. ";" .. data.label .. "]"
            y = y + 0.4
            formspec = formspec .. [[
            dropdown[]] .. x .. "," .. y .. ";3,0.5;" .. setting .. ";" ..
            dataset_str .. [[;]] .. dataset_selected_id .. [[;true]
            ]]
            if data.tooltip then
                formspec = formspec .. [[
                tooltip[]] .. setting .. ";" .. data.tooltip .. [[]
                ]]
            end
            y = y + 0.2
        elseif data.type == "list" then
            y = y + 0.3
            formspec = formspec .. [[
            tablecolumns[color;text]
            table[]] .. x-0.0125 .. "," .. y .. ";3.8125,2.5;" .. setting .. ";" ..
            mail.get_color("header") .. "," .. data.label .. ",," ..
            table.concat(field_default, ",,") .. "]"

            y = y + 3.1
            formspec = formspec .. [[
            field[]] .. x+0.275 .. "," .. y .. ";2.975,0.5;field_" .. setting .. [[;;]
            button[]] .. x+2.75 .. "," .. y-0.325 .. ";0.75,0.5;add_" .. setting .. [[;+]
            button[]] .. x+3.25 .. "," .. y-0.325 .. ";0.75,0.5;remove_" .. setting .. [[;-]
            ]]

            if data.tooltip then
                formspec = formspec .. "tooltip[field_" .. setting .. ";" .. data.tooltip .. "]"
            end

            y = y - 0.4
        end
    end
    formspec = formspec .. mail.theme
	minetest.show_formspec(name, FORMNAME, formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= FORMNAME then
		return
	end

    local playername = player:get_player_name()

    for setting, data in pairs(mail.settings) do
        if fields[setting] or fields["add_" .. setting] or fields["remove_" .. setting] then
            if data.type == "bool" then
                mail.selected_idxs[setting][playername] = fields[setting] == "true"
                break
            elseif data.type == "string" then
                if data.dataset and fields["dataset_" .. setting] then
                    mail.selected_idxs[setting][playername] = data.dataset[tonumber(fields["dataset_" .. setting])]
                end
                mail.show_settings(playername)
            elseif data.type == "index" then
                mail.selected_idxs[setting][playername] = tonumber(fields[setting])
            elseif data.type == "list" then
                mail.selected_idxs[setting][playername] = mail.selected_idxs[setting][playername] or
                mail.get_setting(playername, setting)
                if fields[setting] then
                    local evt = minetest.explode_table_event(fields[setting])
                    mail.selected_idxs["index_" .. setting][playername] = evt.row-1
                elseif fields["add_" .. setting] then
                    table.insert(mail.selected_idxs[setting][playername], fields["field_" .. setting])
                elseif fields["remove_" .. setting] and mail.selected_idxs["index_" .. setting][playername] then
                    table.remove(mail.selected_idxs[setting][playername],
                    mail.selected_idxs["index_" .. setting][playername])
                end
                mail.show_settings(playername)
            end
        end
    end

	if fields.back then
		mail.show_mail_menu(playername)
		return

    elseif fields.groups then
        local evt = minetest.explode_table_event(fields.groups)
        mail.selected_idxs.settings_group[playername] = mail.settings_groups[tonumber(evt.row)].name
        mail.show_settings(playername)
    elseif fields.optionstab == "1" then
        mail.selected_idxs.optionstab[playername] = 1

    elseif fields.optionstab == "2" then
        mail.selected_idxs.optionstab[playername] = 2
        mail.show_about(playername)
        return

    elseif fields.save then
        -- save settings
        for setting, _ in pairs(mail.settings) do
            local new_value = mail.selected_idxs[setting][playername]
            mail.selected_idxs[setting][playername] = nil
            if new_value == nil then new_value = mail.get_setting(playername, setting) end
            mail.set_setting(playername, setting, new_value)
        end
        -- update visuals
        mail.hud_update(playername, mail.get_storage_entry(playername).inbox)
        mail.show_settings(playername)

    elseif fields.reset then
        mail.reset_settings(playername)
        mail.show_settings(playername)
    end
	return
end)
