require 'bobot/events/common'
require 'bobot/events/message'
require 'bobot/events/message_echo'
require 'bobot/events/delivery'
require 'bobot/events/postback'
require 'bobot/events/optin'
require 'bobot/events/read'
require 'bobot/events/account_linking'
require 'bobot/events/referral'
require 'bobot/events/policy_enforcement'
require 'bobot/events/pass_thread_control'
require 'bobot/events/take_thread_control'

module Bobot
  module Event
    EVENTS = {
      'message' => Message,
      'delivery' => Delivery,
      'postback' => Postback,
      'optin' => Optin,
      'read' => Read,
      'account_linking' => AccountLinking,
      'referral' => Referral,
      'message_echo' => MessageEcho,
      'policy-enforcement' => PolicyEnforcement,
      'pass_thread_control' => PassThreadControl,
      'take_thread_control' => TakeThreadControl,
    }.freeze

    def self.parse(payload)
      return MessageEcho.new(payload) if payload_is_echo?(payload)

      EVENTS.each do |event, klass|
        return klass.new(payload) if payload.key?(event)
      end

      raise UnknownPayload.new(payload)
    end

    def self.payload_is_echo?(payload)
      payload.key?('message') && payload['message']['is_echo'] == true
    end

    class UnknownPayload < Bobot::Error; end
  end
end
