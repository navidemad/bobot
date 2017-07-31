module Bobot
  module User
    include Bobot::GraphFacebook

    def get_profile(query:)
      graph_get "/#{query.fetch(:fb_id)}", query: {
        fields: query.fetch(:fields).join(','),
        access_token: query.fetch(:access_token),
      }
    end
    module_function :get_profile
  end
end
