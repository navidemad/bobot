module Bobot
  module Event
    class AccountLinking
      include Bobot::Event::Common

      def status
        @messaging['account_linking']['status']
      end

      def authorization_code
        @messaging['account_linking']['authorization_code']
      end
    end
  end
end
