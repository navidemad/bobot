module Bobot
  module Event
    class Optin
      include Bobot::Event::Common

      def ref
        @messaging['optin']['ref']
      end
    end
  end
end
