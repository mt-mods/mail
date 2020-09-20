
-- send request from webmail
function mail.handlers.send(sendmail)
	-- send mail from webclient
	minetest.log("action", "[webmail] sending mail from webclient: " .. sendmail.from .. " -> " .. sendmail.to)
	mail.send(sendmail)
end
