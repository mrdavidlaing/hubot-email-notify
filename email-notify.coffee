# Allows Hubot to send email notification whenever a @mentioned user is not in the room. 
# With this script you can have the exatly same notifications and mentioning system as in Hipchat ;-)


# Environment Variables:
#
# HUBOT_EMAIL_HOST 		 - The email host where you will send the email from (ex "smtp.gmail.com")
# HUBOT_EMAIL_USERNAME   - The username of the email accoun that hubot will use to send email notification
# HUBOT_EMAIL_PASSWORD   - The password for the email account 
# HUBOT_EMAIL_USER_*     - Users email address (for example: HUBOT_EMAIL_USER_NICK="thanks@beyounic.com")
# HUBOT_GITHUB_TOKEN     - GH OAuth2 Token, (if you using the campfire adaptor you should have it already there)
# HUBOT_CAMPFIRE_ACCOUNT - See campfire adapter

# This script require https http://nodejs.org/api/https.html (you should be fine with this already)
# This script require Mail (details at: https://github.com/weaver/node-mail) / npm install mail 

https = require("https")

module.exports = (robot) ->

    
  robot.hear /@(\w+)/i, (msg) ->

    senderName   = msg.message.user.name #chi scrive il messaggio (mittente)
    mentionedUser = msg.match[1].toUpperCase() #chi viene notificato (destinatario)
    message  = msg.message.text
    mentionedEmail = process.env["HUBOT_EMAIL_USER_#{mentionedUser}"]
    campfireAccount = process.env.HUBOT_CAMPFIRE_ACCOUNT
    campfireToken = process.env.HUBOT_CAMPFIRE_TOKEN

    options =
      host: campfireAccount + ".campfirenow.com"
      port: 443
      path: "/room/" + msg.message.user.room + ".json"
      method: "GET"
      auth: campfireToken + ":x"

    req = https.request(options, (res) ->
      res.on "data", (data) ->
        roomData = JSON.parse(data.toString())
        roomName = roomData.room.name
        mail = require("mail").Mail(
          host: process.env.HUBOT_EMAIL_HOST
          username: process.env.HUBOT_EMAIL_USERNAME
          password: process.env.HUBOT_EMAIL_PASSWORD
        )

        for own key, user of robot.brain.data.users
          unless mentionedUser is user.name.toUpperCase()

            mail.message(
              from: "jack@beyounic.com"
              to: [ mentionedEmail ]
              subject: senderName + " mentioned you in the room \"" + roomName + "\""
              ).body("Hi " + mentionedUser + ",\n\n" + senderName + " just mentioned you in the https://" + campfireAccount + ".campfirenow.com/room/" + user.room + "/transcript but you\'re not there: \n\n" + senderName + ": " + message).send (err) ->
                throw err  if err
            console.log(senderName)
            console.log(mentionedUser)
            console.log(message)
            console.log(mentionedEmail)

    )
    req.end()
      