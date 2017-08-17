module Bobot
  module Profile
    include Bobot::GraphFacebook

    def set(body:, query: nil)
      query ||= { access_token: Bobot.page_access_token }
      query[:access_token] = Bobot.page_access_token unless query.key?("access_token")
      graph_post '/me/messenger_profile', body: body, query: {
        access_token: query.fetch(:access_token),
      }
    end
    module_function :set

    def unset(body:, query: nil)
      query ||= { access_token: Bobot.page_access_token }
      query[:access_token] = Bobot.page_access_token unless query.key?("access_token")
      graph_delete '/me/messenger_profile', body: body, query: {
        access_token: query.fetch(:access_token),
      }
    end
    module_function :unset
  end
end
