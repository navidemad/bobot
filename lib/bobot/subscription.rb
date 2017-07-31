module Bobot
  module Subscription
    include Bobot::GraphFacebook

    def set(query: {})
      graph_post "/#{query.fetch(:page_id)}/subscribed_apps", query: {
        access_token: query.fetch(:access_token),
      }
    end
    module_function :set

    def unset(query: {})
      graph_delete "/#{query.fetch(:page_id)}/subscribed_apps", query: {
        access_token: query.fetch(:access_token),
      }
    end
    module_function :unset
  end
end
