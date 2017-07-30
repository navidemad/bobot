module Bobot
  module Event
    # The Delivery class represents the receipt of a delivered message.
    class Delivery
      include Bobot::Event::Common

      def ids
        @messaging['delivery']['mids']
      end

      def at
        Time.zone.at(@messaging['delivery']['watermark'] / 1000)
      end

      def seq
        @messaging['delivery']['seq']
      end
    end
  end
end
