module Bobot
  class Configuration
    attr_accessor :app_id, :app_secret, :verify_token, :skip_code, :domains, :async, :commander_queue_name, :url_for_chat_extension, :size_for_chat_extension, :share_button_for_chat_extension, :in_test_for_chat_extension, :pages

    def domains=(rhs)
      if rhs.nil?
        @domains = nil
      elsif rhs.respond_to?(:to_str)
        @domains = rhs.split(",").map(&:strip)
      elsif rhs.is_a?(Array)
        @domains = rhs
      else
        raise Bobot::FieldFormat.new("domains should be a string or an array")
      end
    end
  end
end
