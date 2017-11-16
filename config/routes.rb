Bobot::Engine.routes.draw do
  controller 'webhook' do
    match 'facebook', action: :webhook, via: [:get, :post]
  end
end
