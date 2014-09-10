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
          notifications = user.notifications
          notif_info = notifications.map{|notif| notif.api_detail}
          {data:notif_info, message:{type:'success',value:'notifications', code: 0}}
        else
          {data:[], message:{type:'error',value:'Can not find this user', code: 0}}
        end
      end

      # Delete notification
      # POST: /api/v1/notifications/delete
      # parameters:
      #   token               String *required
      #   notification_id     String *required
      post :delete do
        user            = User.find_by_auth_token(params[:token])
        notification_id = params[:notification_id]
        if user.present?
          notification  = Notification.find(notification_id)
          notification.destroy
          {data:[], message:{type:'success',value:'deleted notification', code: 0}}
        else
          {data:[], message:{type:'error',value:'Can not find this user', code: 0}}
        end
      end
      
      # Delete notification
      # POST: /api/v1/notifications/had_read_notification
      # parameters:
      #   token               String *required
      #   notification_id     String *required
      post :had_read_notification do
        user    = User.find_by_auth_token(params[:token])        
        if user.present?
          notif  = Notification.find(params[:notification_id])
          notif.update_attributes(is_read:true)
          {data:[], message:{type:'success',value:'read notifications', code: 0}}
        else
          {data:[], message:{type:'error',value:'Can not find this user', code: 0}}
        end
      end

    end #notifications
  end
end
