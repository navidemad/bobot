module Bobot
  module Subscriptions
    SUBSCRIPTIONS_URL = 'https://graph.facebook.com/v2.10'.freeze

    include Network

    format :json

    base_uri SUBSCRIPTIONS_URL

    headers 'Content-Type' => 'application/json; charset=utf-8'
    headers 'Accept' => 'application/json'

    def set(settings, access_token:)
      page_id = settings.fetch(:page_id)
      response = post "/#{page_id}/subscribed_apps", query: {
        access_token: access_token,
      }
      Bobot::ErrorParser.raise_errors_from(response)
      true
    end
    module_function :set

    def unset(settings, access_token:)
      page_id = settings.fetch(:page_id)
      response = delete "/#{page_id}/subscribed_apps", query: {
        access_token: access_token,
      }
      Bobot::ErrorParser.raise_errors_from(response)
      true
    end
    module_function :unset
  end
end
