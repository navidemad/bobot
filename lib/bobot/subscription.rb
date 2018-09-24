module Bobot
  module Subscription
    include Bobot::GraphFacebook

    def get(query:)
      graph_get "/me/subscribed_apps", query: query
    end
    module_function :get
  
    def set(query:)
      graph_post "/#{query.fetch(:page_id)}/subscribed_apps", query: query
    end
    module_function :set

    def unset(query:)
      graph_delete "/#{query.fetch(:page_id)}/subscribed_apps", query: query
    end
    module_function :unset
  end
end
