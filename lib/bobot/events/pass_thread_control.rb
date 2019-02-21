module Bobot
  module Event
    class PassThreadControl
      include Bobot::Event::Common

      def new_owner_app_id
        @messaging['pass_thread_control']['new_owner_app_id']
      end

      def metadata
        @messaging['pass_thread_control']['metadata']
      end
    end
  end
end
