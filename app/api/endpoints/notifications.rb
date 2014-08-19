module Endpoints
  class Notifications < Grape::API

    resource :notifications do      
      get :ping do
        {success: 'test notifications'}
      end      

      # Accept Friend
      # GET: /api/v1/notifications
      # parameters:
      #   token               String *required      
      get do
        user = User.find_by_auth_token(params[:token])
        if user.present?
          notifications = user.unread_notifications
          notif_info = notifications.map{|notif| notif.api_detail}
          {data:notif_info, message:{type:'success',value:'notifications', code: 0}}
        else
          {data:[], message:{type:'error',value:'Can not find this user', code: 0}}
        end
      end

    end #notifications
  end
end
