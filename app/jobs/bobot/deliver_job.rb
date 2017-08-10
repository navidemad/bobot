module Bobot
  class DeliverJob < ApplicationJob
    queue_as :default

    def perform(sender:, access_token:, payload_template:)
      Bobot::Commander.deliver(
        body: {
          recipient: sender,
        }.merge(payload_template),
        query: {
          access_token: access_token,
        },
      )
    end
  end
end
