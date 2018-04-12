module Bobot
  module Event
    class PolicyEnforcement
      include Bobot::Event::Common

      def action
        @messaging['policy-enforcement']['action']
      end

      def reason
        @messaging['policy-enforcement']['reason']
      end
    end
  end
end
