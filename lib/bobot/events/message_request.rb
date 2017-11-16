module Bobot
  module Event
    class MessageRequest < Message
      def accept?
        @messaging['message_request'] == 'accept'
      end
    end
  end
end
