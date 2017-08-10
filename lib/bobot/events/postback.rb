module Bobot
  module Event
    class Postback
      include Bobot::Event::Common

      def payload
        @messaging['postback']['payload']
      end

      def title
        @messaging['postback']['title']
      end

      def referral
        return if @messaging['postback']['referral'].nil?
        @referral ||= Referral::Referral.new(@messaging['postback']['referral'])
      end
    end
  end
end
