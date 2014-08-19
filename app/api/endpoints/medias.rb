module Endpoints
  class Medias < Grape::API

    resource :medias do
      # test medias api
      get :ping do
        {success: "Media Endpoints"}
      end
      


    end #end medias
  end
end
