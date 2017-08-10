Bobot::Commander.on :message do |message|
  klass = message.quick_reply.present? ? Bobot::Postback : Bobot::Message
  klass.perform(message)
end

Bobot::Commander.on :postback do |postback|
  klass = Bobot::Postback
  klass.perform(postback)
end

# Bobot::Commander.on :optin do |optin|
#   optin.reply_with_text(text: 'Ah, human! Clicked on Send To Messenger')
# end
#
# Bobot::Commander.on :referral do |referral|
#   optin.reply_with_text(text: "Great you came from #{referal.ref}")
# end
