module Network
  module ClassMethods
    [:get, :post, :put, :patch, :delete, :move, :copy, :head, :options, :mkcol].each do |verb|
      define_method(verb) do |path, options = {}, &block|
        HTTParty.send(verb, path, default_options.merge(options), &block).tap do |response|
          if Bobot.debug_log
            puts "[#{response.request.http_method}] #{response.request.base_uri}#{response.request.path}"
            puts 'Body:'
            ap JSON.parse(response.request.send(:body) || '{}')
            puts 'Response:'
            ap response.parsed_response
          end
          Bobot::ErrorParser.raise_errors_from(response)
          if response.client_error? || response.server_error?
            raise Bobot::NetworkError.new(response, response.parsed_response.to_s)
          end
          response
        end
      end
    end
  end

  def self.included(base)
    base.include(HTTParty)
    base.extend(Network::ClassMethods)
  end
end
