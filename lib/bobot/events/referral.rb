module Bobot
  module Event
    class Referral
      include Bobot::Event::Common

      class Referral
        def initialize(referral)
          @referral = referral
        end

        def ref
          @referral['ref']
        end

        def source
          @referral['source']
        end

        def type
          @referral['type']
        end
      end

      def referral
        @referral ||= Referral.new(@messaging['referral'])
      end

      def ref
        referral.ref
      end
    end
  end
end
