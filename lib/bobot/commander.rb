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
    ].freeze

    include Bobot::GraphFacebook

    class << self
      def deliver(body:, query:)
        graph_post '/me/messages', body: body, query: {
          access_token: query.fetch(:access_token),
        }
      end

      def on(event, &block)
        unless EVENTS.include? event
          raise Error.new("#{event} is not a valid event; available events are #{EVENTS.join(',')}")
        end
        hooks[event] = block
      end

      def receive(payload)
        event = Bobot::Event.parse(payload)
        hooks.fetch(Bobot::Event::EVENTS.invert[event.class].to_sym)
        Rails.logger.debug "[ActiveJob] << Bobot::HookJob with event #{event.class}"
        # event.mark_as_seen
        job = Bobot::CommanderJob
        if Bobot.config.async
          job.perform_later(payload: payload)
        else
          job.perform_now(payload: payload)
        end
      rescue KeyError
        warn "[receive] Ignoring #{event.class} (no hook registered)"
      end

      def trigger(payload)
        event = Bobot::Event.parse(payload)
        hook = hooks.fetch(Bobot::Event::EVENTS.invert[event.class].to_sym)
        Rails.logger.debug "[ActiveJob] >> Bobot::HookJob related to event #{name.class}"
        # event.show_typing(state: true)
        hook.call(event)
        # event.show_typing(state: false)
        event
      rescue KeyError
        warn "[trigger] Ignoring #{event.class} (no hook registered)"
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
