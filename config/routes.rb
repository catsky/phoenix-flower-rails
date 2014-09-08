PhoenixFlower::Application.routes.draw do

  # API
  namespace :api, constraints: { format: /(json)/ }, defaults: { format: :json } do
    
    namespace :v1 do      
      get :ping, action: "ping"
      
      namespace :weixin do
        get ":weixin", action: "weixin_access_verify"
      end

    end

  end
end
