module Bobot
  class Postback
    def self.perform(event)
      payload = event.payload
      begin
        payload = ActiveSupport::JSON.decode(payload)
        step    = payload["step"]
        params  = payload["params"].hash
      rescue ::ActiveSupport::JSON.parse_error
        step    = payload.to_sym
        params  = nil
      end

      bot = Postback.new(event)
      if bot.respond_to?(step)
        bot.public_send(*([step, params].compact))
      else
        bot.unknown_payload
      end
    end
  end
end
