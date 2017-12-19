require "typhoeus"
require "uri"

module Bobot
  module GraphFacebook
    GRAPH_FB_URL = 'https://graph.facebook.com/v2.11'.freeze
    GRAPH_HEADERS = { Accept: "application/json", "Content-Type" => "application/json; charset=utf-8" }.freeze

    module ClassMethods
      def graph_get(path, query: {})
        url = "#{GRAPH_FB_URL}#{path}".freeze
        response = ::Typhoeus::Request.get(
          url,
          params: URI.encode_www_form(query.reverse_merge(include_headers: false)),
          headers: GRAPH_HEADERS,
          ssl_verifypeer: false,
        )
        json = ActiveSupport::JSON.decode(response.send(:body) || '{}')
        Rails.logger.debug "[GET] >> #{url}"
        Rails.logger.debug "[GET] << #{json}"
        Bobot::ErrorParser.raise_errors_from(json)
        json
      end
      module_function :graph_get

      def graph_post(path, query: {}, body: {})
        url = "#{GRAPH_FB_URL}#{path}".freeze
        response = ::Typhoeus::Request.post(
          url,
          params: URI.encode_www_form(query.reverse_merge(include_headers: false)),
          body: ActiveSupport::JSON.encode(body),
          headers: GRAPH_HEADERS,
          ssl_verifypeer: false,
        )
        json = ActiveSupport::JSON.decode(response.send(:body) || '{}')
        Rails.logger.debug "[POST] >> #{url}"
        Rails.logger.debug "[POST] << #{json}"
        Bobot::ErrorParser.raise_errors_from(json)
        json
      end
      module_function :graph_post

      def graph_delete(path, query: {}, body: {})
        url = "#{GRAPH_FB_URL}#{path}".freeze
        response = ::Typhoeus::Request.delete(
          url,
          params: URI.encode_www_form(query.reverse_merge(include_headers: false)),
          body: ActiveSupport::JSON.encode(body),
          headers: GRAPH_HEADERS,
          ssl_verifypeer: false,
        )
        json = ActiveSupport::JSON.decode(response.send(:body) || '{}')
        Rails.logger.debug "[DELETE] >> #{url}"
        Rails.logger.debug "[DELETE] << #{json}"
        Bobot::ErrorParser.raise_errors_from(json)
        json
      end
      module_function :graph_delete
    end

    module InstanceMethods
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end
