module Bobot
  module GraphFacebook
    GRAPH_FB_URL = 'https://graph.facebook.com'.freeze
    GRAPH_FB_VERSION = 'v2.11'.freeze

    module ClassMethods
      def graph_get(path, query: {})
        uri = URI.parse(File.join(GRAPH_FB_URL, GRAPH_FB_VERSION, path))
        uri.query = URI.encode_www_form(query)
        req = Net::HTTP::Get.new(uri.request_uri)
        req['Content-Type'] = 'application/json; charset=utf-8'
        req['Accept'] = 'application/json'
        req['User-Agent'] = nil
        req['Accept-Encoding'] = nil
        https = Net::HTTP.new(uri.host, uri.port).tap do |http|
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http.read_timeout = 300
        end
        res = https.request(req)
        json = ActiveSupport::JSON.decode(res.send(:body) || '{}')
        if Bobot.config.debug_log
          puts "[GET] >> #{uri.request_uri}"
          puts "[GET] << #{json}"
        end
        Bobot::ErrorParser.raise_errors_from(json)
        json
      end
      module_function :graph_get

      def graph_post(path, query: {}, body: {})
        uri = URI.parse(File.join(GRAPH_FB_URL, GRAPH_FB_VERSION, path))
        uri.query = URI.encode_www_form(query)
        req = Net::HTTP::Post.new(uri.request_uri)
        req['Content-Type'] = 'application/json; charset=utf-8'
        req['Accept'] = 'application/json'
        req['User-Agent'] = nil
        req['Accept-Encoding'] = nil
        req.body = ActiveSupport::JSON.encode(body)
        https = Net::HTTP.new(uri.host, uri.port).tap do |http|
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http.read_timeout = 300
        end
        res = https.request(req)
        json = ActiveSupport::JSON.decode(res.send(:body) || '{}')
        if Bobot.config.debug_log
          puts "[POST] >> #{uri.request_uri}"
          puts "[POST] << #{json}"
        end
        Bobot::ErrorParser.raise_errors_from(json)
        json
      end
      module_function :graph_post

      def graph_delete(path, query: {}, body: {})
        uri = URI.parse(File.join(GRAPH_FB_URL, GRAPH_FB_VERSION, path))
        uri.query = URI.encode_www_form(query)
        req = Net::HTTP::Delete.new(uri.request_uri)
        req['Content-Type'] = 'application/json; charset=utf-8'
        req['Accept'] = 'application/json'
        req['User-Agent'] = nil
        req['Accept-Encoding'] = nil
        req.body = ActiveSupport::JSON.encode(body)
        https = Net::HTTP.new(uri.host, uri.port).tap do |http|
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http.read_timeout = 300
        end
        res = https.request(req)
        json = ActiveSupport::JSON.decode(res.send(:body) || '{}')
        if Bobot.config.debug_log
          puts "[DELETE] >> #{uri.request_uri}"
          puts "[DELETE] << #{json}"
        end
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
