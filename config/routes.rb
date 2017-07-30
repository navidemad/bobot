Bobot::Engine.routes.draw do
  controller 'webhook' do
    match 'facebook', action: :notify, via: :post, as: :facebook_notify
    match 'facebook', action: :verify, via: :get, as: :facebook_verify
  end
end
