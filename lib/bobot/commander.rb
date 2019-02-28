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
      pass_thread_control
      take_thread_control
    ].freeze

    include Bobot::GraphFacebook

    class << self
      def deliver(endpoint: '/me/messages', body:, query:)
        graph_post(
          endpoint,
          body: body,
          query: {
            access_token: query.fetch(:access_token),
          },
        )
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
        event.mark_as_seen if event.page.present? && [Bobot::Event::MessageEcho, Bobot::Event::PassThreadControl, Bobot::Event::TakeThreadControl].none? { |c| event.is_a?(c) }
        hooks.fetch(Bobot::Event::EVENTS.invert[event.class].to_sym)
        Bobot::CommanderJob.send(
          Bobot.config.async ? :perform_later : :perform_now,
          { payload: payload },
        )
      rescue KeyError
        warn "[bobot trigger] Ignoring #{event.class} (no hook registered)"
      end

      def trigger(payload)
        event = Bobot::Event.parse(payload)
        return if !event.page.present?

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
