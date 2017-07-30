module Bobot
  module Event
    class Read
      include Bobot::Event::Common

      def at
        Time.zone.at(@messaging['read']['watermark'] / 1000)
      end

      def seq
        @messaging['read']['seq']
      end
    end
  end
end
