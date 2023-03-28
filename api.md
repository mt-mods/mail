
# Mail format
The mail format in the api hooks

```lua
mail = {
	from = "sender name",
	to = "players, which, are, addressed",
	cc = "carbon copy",
	bcc = "players, which, get, a, copy, but, are, not, visible, to, others",
	subject = "subject line",
	body = "mail body"
}
```

The fields `to`, `cc` and `bcc` can contain a player, multiple player names separated by commas, or be empty.
Players in `to` are the recipiants, who are addressed directly. `cc` specifies players that get the mail to get notified, but are not immediate part of the conversation.
There is no technical difference between `to` and `cc`, it just implies meaning for the players.
Players can see all fields making up the mail except `bcc`, which is the only difference to `cc`.

## Sending mail

```lua
local success, error = mail.send({
	from = "singleplayer",
	to = "playername",
	cc = "carbon, copy",
	bcc = "blind, carbon, copy",
	subject = "subject line",
	body = "mail body"
})

-- if "success" is false the error parameter will contain a message
```

# Hooks
On-receive mail hook:

```lua
mail.register_on_receive(function(m)
	-- "m" is an object in the form: "Mail format"
end)
```

# Internals

mod-storage entry for a player (indexed by playername and serialized with json):
```lua
{
	contacts = {
		{
			-- name of the player (unique key in the list)
			name = "",
			-- note
			note = ""
		},{
			...
		}
	},
	inbox = {
		{
			-- globally unique mail id
			id = "d6cce35c-487a-458f-bab2-9032c2621f38",
			-- sending player name
			from = "",
			-- receiving player name
			to = "",
			-- carbon copy (optional)
			cc = "playername, playername2",
			-- blind carbon copy (optional)
			bcc = "",
			-- mail subject
			subject = "",
			-- mail body
			body = "",
			-- timestamp (os.time())
			time = 1234,
			-- read-flag (true: player has read the mail, inbox only)
			read = true
		},{
			...
		}
	},
	outbox = {
		-- same format as "inbox"
	},
	lists = {
		{
			-- name of the maillist (unique key in the list)
			name = "",
			-- description
			description = "",
			-- playername list
			players = {"playername", "playername2"}
		}
	}
}
