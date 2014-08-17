module Endpoints
  class Friends < Grape::API

    resource :friends do
      
      desc "Get Friends list"
      get do
      end

      desc "Get Friend info"      
      get :friend_info do
      end

      
      desc "Search Friend"
      get :search_friend do
      end

      desc "Search friends by access token"
      get :friend_by_access_token do
      end

    end
  end
end
