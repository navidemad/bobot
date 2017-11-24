module Bobot
  class DeliverJob < ApplicationJob
    queue_as :default

    def perform(target_facebook_uid:, access_token:, payload_template:)
      Bobot::Commander.deliver(
        body: {
          recipient: target_facebook_uid,
        }.merge(payload_template),
        query: {
          access_token: access_token,
        },
      )
    end
  end
end
