module Bobot
  module Profile
    PROFILE_URL = 'https://graph.facebook.com/v2.10/me'.freeze

    include Network

    format :json

    base_uri PROFILE_URL

    headers 'Content-Type' => 'application/json; charset=utf-8'
    headers 'Accept' => 'application/json'

    def set(settings, access_token:)
      response = post '/messenger_profile', body: settings.to_json, query: {
        access_token: access_token,
      }
      Bobot::ErrorParser.raise_errors_from(response)
      true
    end
    module_function :set

    def unset(settings, access_token:)
      response = delete '/messenger_profile', body: settings.to_json, query: {
        access_token: access_token,
      }
      Bobot::ErrorParser.raise_errors_from(response)
      true
    end
    module_function :unset
  end
end
