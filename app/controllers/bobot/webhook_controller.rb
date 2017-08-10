module Bobot
  class WebhookController < Bobot::ApplicationController
    include ActionView::Helpers::TextHelper

    skip_before_action :verify_authenticity_token, raise: false

    layout :bobot_layout rescue nil

    def notify
      if check_integrity?
        begin
          trigger(parsed_body)
        ensure
          respond_with status: :ok
        end
      else
        respond_with status: :forbidden
      end
    end

    def verify
      if verify_params['hub.mode'] == 'subscribe' &&
         verify_params['hub.verify_token'] == Bobot.verify_token
        respond_with body: params['hub.challenge'], status: :ok
      else
        respond_with status: :forbidden
      end
    end

  private

    def body
      @body ||= request.body.read
    end

    def parsed_body
      @parsed_body ||= JSON.parse(body)
    end

    def signature(str, key = nil)
      key ||= Bobot.app_secret
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), key, str)
    end

    def check_integrity?
      request.headers['HTTP_X_HUB_SIGNATURE'].to_s =~ /\Asha1=([0-9a-z]{40})\z/
      hub_signature = Regexp.last_match(1)
      hub_signature && Rack::Utils.secure_compare(hub_signature, signature(body))
    end

    def trigger(events)
      events['entry'].each do |entry|
        if entry['messaging'].present?
          entry['messaging'].each { |messaging| Bobot::Commander.receive(messaging) }
        end
      end
    end

    def respond_with(body: '', status:)
      self.response_body = body
      self.status = status
    end

    def verify_params
      params.permit('hub.mode', 'hub.challenge', 'hub.verify_token')
    end

    def bobot_layout
      'bobot/application'
    end
  end
end
