module Bobot
  module Event
    class MessageEcho < Message
      def access_token
        Bobot.config.find_page_by_id(sender["id"]).try(:page_access_token)
      end
    end
  end
end
