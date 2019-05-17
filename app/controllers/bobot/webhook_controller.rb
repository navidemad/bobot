module Bobot
  class WebhookController < Bobot::ApplicationController
    class BadRequestError < Error; end

    X_HUB_SIGNATURE_MISSING_WARNING = <<-HEREDOC.freeze
      The X-Hub-Signature header is not present in the request. This is
      expected for the first webhook requests. If it continues after
      some time, check your app's secret token.
    HEREDOC

    OPEN_SSL_AUTHENTICATION_CODE = OpenSSL::Digest.new('sha1'.freeze)

    def webhook
      if request.get?
        verify
      elsif request.post?
        receive
      else
        head :method_not_allowed
      end
    end

    def verify
      if params['hub.mode'.freeze] == 'subscribe' &&
         params['hub.verify_token'.freeze] == Bobot.config.verify_token
        render plain: params['hub.challenge'.freeze], status: :ok
      else
        render plain: "Error wrong verify token".freeze, status: :forbidden
      end
    end

    def receive
      @body = nil
      @parsed_body = nil
      check_integrity unless skip_check_integrity?
      trigger(parsed_body)
      head :ok
    rescue => e
      render plain: e.message, status: :ok
    end

  private

    def body
      @body ||= request.body.read
    end

    def parsed_body
      @parsed_body ||= ActiveSupport::JSON.decode(body)
    rescue ::ActiveSupport::JSON.parse_error
      raise BadRequestError.new("Error parsing request body format".freeze)
    end

    def valid_signature?
      Rack::Utils.secure_compare(signature, signature_for(body))
    end

    def generate_hmac(content)
      OpenSSL::HMAC.hexdigest(self.class::OPEN_SSL_AUTHENTICATION_CODE, Bobot.config.app_secret, content)
    end

    def signature_for(string)
      format('sha1=%<sha1>s'.freeze, sha1: generate_hmac(string))
    end

    def signature
      request.headers['HTTP_X_HUB_SIGNATURE'.freeze].to_s
    end

    def skip_check_integrity?
      request.params['skip_code'.freeze].to_s == Bobot.config.skip_code
    end

    def check_integrity
      signature =~ /\Asha1=([0-9a-z]{40})\z/
      hub_signature = Regexp.last_match(1)
      unless hub_signature
        Rails.logger.error(self.class::X_HUB_SIGNATURE_MISSING_WARNING)
        raise BadRequestError.new("Error getting integrity signature".freeze)
      end
      raise BadRequestError.new("Error checking message integrity".freeze) unless valid_signature?
    end

    def trigger(events)
      events['entry'.freeze].to_a.each do |entry|
        entry['messaging'.freeze].to_a.each do |messaging|
          Bobot::Commander.receive(messaging)
        end
        entry['standby'.freeze].to_a.each do |standby|
          Bobot::Commander.receive(standby) if standby["message".freeze]
        end
      end
    end
  end
end
