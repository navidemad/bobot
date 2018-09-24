module Bobot
  module Profile
    include Bobot::GraphFacebook

    def get(query:)
      graph_get '/me/messenger_profile', query: query
    end
    module_function :get

    def set(body:, query:)
      graph_post '/me/messenger_profile', body: body, query: query
    end
    module_function :set

    def unset(body:, query:)
      graph_delete '/me/messenger_profile', body: body, query: query
    end
    module_function :unset
  end
end
