Bobot::Commander.on :message do |message|
  message.reply_with_text(text: "Hello, human! My reply to your message: '#{message.text}'")
end

Bobot::Commander.on :postback do |postback|
  if postback.payload == 'WHAT_IS_A_CHATBOT'
    postback.reply_with_text(text: I18n.t('bobot.what_is_a_chatbot'))
  end
end

Bobot::Commander.on :optin do |optin|
  optin.reply_with_text(text: "Ah, human! Clicked on Send To Messenger your came from '#{ref}'")
end

Bobot::Commander.on :referral do |referral|
  referral.reply_with_text(text: "Great you came from #{referal.ref}")
end
