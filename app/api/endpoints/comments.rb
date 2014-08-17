module Endpoints
  class Comments < Grape::API

    resource :comments do
      
      get :ping do
        {success:'lost_founds test'}
      end

      

    end #// resouce
  end
end
