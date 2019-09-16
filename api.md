
# Mail format
The mail format in the api hooks

```lua
mail = {
	sender = "source name",
	receiver = "destination name",
	subject = "subject line",
	body = "mail body",
	-- 8 attachments max
	attachments = {"default:stone 99", "default:gold_ingot 99"}
}
```

## Sending mail
Old variant (pre-1.1)
```lua
mail.send("source name", "destination name", "subject line", "mail body")
```

New variant (1.1+)
```lua
mail.send({
	sender = "source name",
	receiver = "destination name",
	subject = "subject line",
	body = "mail body"
})
```

# Hooks
On-receive mail hook:

```lua
mail.register_on_receive(function(m)
	-- "m" is an object in the form: "Mail format"
end)
```

# internal mail format (on-disk)
The mail format on-disk

> (worldfolder)/mails/(playername).json

```json
[{
	"unread": true,
	"sender": "sender name",
	"receiver": "receiver name",
	"subject": "subject name",
	"body": "main\nmultiline\nbody",
	"time": 1551258349,
	"attachments": [
		"default:stone 99",
		"default:gold_ingot 99"
	]
}]

```
