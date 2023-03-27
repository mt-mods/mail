Mail mod for Minetest (ingame mod)
======

![](https://github.com/mt-mods/mail/workflows/test/badge.svg)
![](https://github.com/mt-mods/mail/workflows/luacheck/badge.svg)


This is a fork of cheapies mail mod

It adds a mail-system that allows players to send each other messages in-game and via webmail (optional)

# Screenshots

Ingame mail
![](pics/ingame.png?raw=true)

# Installation

## In-game mail mod

Install it like any other mod: copy the directory `mail_mod` to your "worldmods" folder

## Webmail

To provide a web-based interface to receive/send mails you can use the [mtui](https://github.com/minetest-go/mtui) project

# Commands/Howto

To access your mail click on the inventory mail button or use the "/mail" command
Mails can be deleted, marked as read or unread, replied to and forwarded to another player

# Compatibility / Migration

Overview:
* `v1` all the data is in the `<worldfolder>/mails.db` file
* `v2` every player has its own (in-) mailbox in the `<worldfolder>/mails/<playername>.json` file
* `v3` every player has an entry in the `<playername>` modstorage (inbox, outbox, contacts)

Mails in the v1 format are supported until commit `b0a5bc7e47ec1c75339e65ec07d0a0ac2b17288b`.
Everything after that assumes either the v2 or v3 is used.

For a v1 to v3 migration the version in `b0a5bc7e47ec1c75339e65ec07d0a0ac2b17288b` has to be at leas run once (startup).

# Dependencies
* None

# License

See the "LICENSE" file

# Textures
* textures/email_mail.png (https://github.com/rubenwardy/email.git WTFPL)

# Contributors

* Cheapie (initial idea/project)
* Rubenwardy (lua/ui improvements)

# Old/Historic stuff
* Old forum topic: https://forum.minetest.net/viewtopic.php?t=14464
* Old mod: https://cheapiesystems.com/git/mail/
