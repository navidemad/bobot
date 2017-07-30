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
    ].freeze

    COMMANDER_URL = 'https://graph.facebook.com/v2.10/me'.freeze

    include Network

    format :json

    base_uri COMMANDER_URL

    headers 'Content-Type' => 'application/json; charset=utf-8'
    headers 'Accept' => 'application/json'

    read_timeout 300

    class << self
      def deliver(message, access_token:)
        response = post '/messages', body: message.to_json, query: {
          access_token: access_token,
        }
        Bobot::ErrorParser.raise_errors_from(response)
        response.body
      end

      def on(event, &block)
        unless EVENTS.include? event
          raise Error.new("#{event} is not a valid event; available events are #{EVENTS.join(',')}")
        end
        hooks[event] = block
      end

      def receive(payload)
        event = Bobot::Event.parse(payload)
        name = Bobot::Event::EVENTS.invert[event.class]
        hooks.fetch(name.to_sym)
        puts "[PUSH JOB] event #{name}" if Bobot.debug_log
        event.mark_as_seen
        Bobot::HookJob.perform_now(payload)
      rescue KeyError
        $stderr.puts "Ignoring #{event} (no hook registered)"
      end

      def trigger(payload)
        event = Bobot::Event.parse(payload)
        name = Bobot::Event::EVENTS.invert[event.class]
        hook = hooks.fetch(name.to_sym)
        puts "[POP JOB] event #{name}" if Bobot.debug_log
        event.show_typing(state: true)
        hook.call(event)
        event.show_typing(state: false)
      rescue KeyError
        $stderr.puts "Ignoring #{event} (no hook registered)"
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
