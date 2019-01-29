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

        def ad_id
          @referral['ad_id'] if @referral.key?('ad_id')
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
