module Bobot
  class DeliverJob < ApplicationJob
    
    queue_as do
      if Bobot.config.commander_queue_name.present?
        Bobot.config.commander_queue_name
      else
        :default
      end
    end

    def perform(target_facebook_uid:, access_token:, payload_template:)
      Bobot::Commander.deliver(
        body: {
          recipient: { id: target_facebook_uid },
        }.merge(payload_template),
        query: {
          access_token: access_token,
        },
      )
    end
  end
end
