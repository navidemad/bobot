module Bobot
  module Commander
    class Error < Bobot::FacebookError; end

    EVENTS = %i[
      message
      delivery
      postback
      optin
      read
      account_linking
      referral
      message_echo
      message_request
      policy-enforcement
    ].freeze

    include Bobot::GraphFacebook

    class << self
      def deliver(body:, query:)
        graph_post '/me/messages', body: body, query: {
          access_token: query.fetch(:access_token),
        }
      end

      def on(event, &block)
        if EVENTS.include? event
          hooks[event] = block
        else
          warn "[bobot trigger] Ignoring #{event.class} (not available in [#{EVENTS.join(', ')}])"
        end
      end

      def receive(payload)
        event = Bobot::Event.parse(payload)
        hooks.fetch(Bobot::Event::EVENTS.invert[event.class].to_sym)
        event.mark_as_seen
        Bobot::CommanderJob.send(
          Bobot.config.async ? :perform_later : :perform_now,
          { payload: payload },
        )
      rescue KeyError
        warn "[bobot trigger] Ignoring #{event.class} (no hook registered)"
      end

      def trigger(payload)
        event = Bobot::Event.parse(payload)
        hook = hooks.fetch(Bobot::Event::EVENTS.invert[event.class].to_sym)
        hook.call(event)
      rescue KeyError
        warn "[bobot trigger] Ignoring #{event.class} (no hook registered)"
      end

      def hooks
        @hooks ||= {}
      end

      def unhook
        @hooks = {}
      end
    end
  end
end
