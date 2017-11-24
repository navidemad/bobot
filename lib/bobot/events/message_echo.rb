module Bobot
  module Event
    class MessageEcho < Message
      def access_token
        Bobot::Page.find(sender["id"])
      end
    end
  end
end
