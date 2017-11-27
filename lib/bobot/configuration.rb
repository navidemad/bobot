module Bobot
  class Configuration
    attr_accessor :app_id, :app_secret, :verify_token, :domains, :async, :commander_queue_name, :pages

    def domains=(rhs)
      if rhs.nil?
        @domains = nil
      elsif rhs.respond_to?(:to_str)
        @domains = rhs.split(",").map(&:strip)
      elsif rhs.is_a?(Array)
        @domains = rhs
      else
        raise Bobot::InvalidParameter.new(:domains, "should be a string or an array")
      end
    end
  end
end
