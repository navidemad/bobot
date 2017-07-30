module Bobot
  module User
    USER_URL = 'https://graph.facebook.com/v2.10'.freeze

    include Network

    format :json

    base_uri USER_URL

    headers 'Content-Type' => 'application/json; charset=utf-8'
    headers 'Accept' => 'application/json'

    def get_profile(fb_id:, fields:, access_token:)
      response = get "/#{fb_id}", query: {
        fields: fields.to_a.join(','),
        access_token: access_token,
      }
      Bobot::ErrorParser.raise_errors_from(response)
      response.parsed_response
    end
    module_function :get_profile
  end
end
