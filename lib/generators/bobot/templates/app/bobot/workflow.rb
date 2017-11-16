# message received or quick replies
Bobot::Commander.on :message do |message|
end

# get started and click on any buttons
Bobot::Commander.on :postback do |postback|
end

# referral by m.me/XXX?ref=
Bobot::Commander.on :referral do |referral|
end

# referral by param ref into send to messenger plugin
Bobot::Commander.on :optin do |optin|
end
