Rails.application.routes.draw do
  mount Bobot::Engine => "/bobot", as: "bobot"
end
