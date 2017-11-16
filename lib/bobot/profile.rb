module Bobot
  module Profile
    include Bobot::GraphFacebook

    def set(body:, query:)
      graph_post '/me/messenger_profile', body: body, query: {
        access_token: query.fetch(:access_token),
      }
    end
    module_function :set

    def unset(body:, query:)
      graph_delete '/me/messenger_profile', body: body, query: {
        access_token: query.fetch(:access_token),
      }
    end
    module_function :unset
  end
end
