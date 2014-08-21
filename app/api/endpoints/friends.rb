module Endpoints
  class Friends < Grape::API

    resource :friends do

      get :ping  do
        {success: TimeChatNet::Application::USER_UNREGISTERED}
      end

      # Get Friend List
      # GET: /api/v1/friends
      # parameters:
      #   token       String *required
      get do
        user = User.find_by_auth_token(params[:token])
        if user.present?          
          friend_info = user.friends.map{|f| {id:f.id.to_s, email:f.email, debug:'Friend List', friend_status:user.is_block(f), time_zone:f.time_zone, username:f.name}}
          {data:friend_info, message:{type:'success',value:'Success query', code: TimeChatNet::Application::SUCCESS_QUERY}}
        else
          {data:[],message:{type:'error',value:'Can not find this user', code: 0}}
        end
      end

      # Get Search Friends
      # GET: /api/v1/friends/search_friends
      # parameters:
      #   token               String *required
      #   emails              String *required  string that splitted by comma
      get :search_friends do
        user    = User.find_by_auth_token(params[:token])
        emails  = params[:email]
        if user.present?
          friends = user.friends.in(email:emails.split(","))
          friend_info = user.friends.map{|f| {id:f.id.to_s, email:f.email, debug:'Search Friends', friend_status:301, time_zone:f.time_zone, username:f.name, block:user.is_block(f)}}
          {data:friend_info, message:{type:'success',value:'Success query', code: TimeChatNet::Application::SUCCESS_QUERY}}
        else
          {data:[], message:{type:'error',value:'Can not find this user', code: 0}}
        end
      end
      
      # Add Friend
      # POST: /api/v1/friends/add_friend
      # parameters:
      #   token               String *required
      #   email               String *required
      post :add_friend do
        email = params[:email]
        user  = User.find_by_auth_token(params[:token])
        if user.present?          
          friend = User.where(email:email).first
          if !user.is_friend(friend) and user.id != friend.id
            if friend.present?
              user.add_friend(friend)
              {data:friend.friend_api_detail(user), message:{type:'success',value:'Added new friend', code: TimeChatNet::Application::SUCCESS_QUERY}}
            else
              {data:[], message:{type:'error',value:'Can not find this friend', code: TimeChatNet::Application::USER_UNREGISTERED}}  
            end
          else
            {data:[], message:{type:'error',value:'Already invited friend', code: TimeChatNet::Application::USER_UNREGISTERED}}
          end
        else
          {data:[], message:{type:'error',value:'Can not find this user', code: TimeChatNet::Application::USER_UNREGISTERED}}
        end
      end

      # Accept Friend
      # POST: /api/v1/friends/accept_friend
      # parameters:
      #   token               String *required
      #   friend_id           String *required
      #   notification_id     String *required
      post :accept_friend do
        user            = User.find_by_auth_token(params[:token])
        friend_id       = params[:friend_id]
        notification_id = params[:notification_id]
        if user.present?
          friend = User.where(id:friend_id).first
          user.accept_friend(friend)
          notification = Notification.where(id:notification_id).first
          notification.read!
          {data:friend.friend_api_detail(user), message:{type:'success',value:'accept new friend', code:TimeChatNet::Application::SUCCESS_QUERY}}
        else
          {data:[], message:{type:'error',value:'Can not find this user', code: 0}}
        end
      end
      
      # Decline Friend
      # POST: /api/v1/friends/decline_friend
      # parameters:
      #   token               String *required
      #   friend_id           String *required
      #   notification_id     String *required
      post :decline_friend do
        user            = User.find_by_auth_token(params[:token])
        friend_id       = params[:friend_id]
        notification_id = params[:notification_id]
        if user.present?
          friend = User.where(id:friend_id).first          
          user.decline_friend(friend)          
          notification = Notification.where(id:notification_id).first
          notification.read!
          {data:friend.friend_api_detail(user), message:{type:'success',value:'decline friend', code: TimeChatNet::Application::SUCCESS_QUERY}}
        else
          {data:[], message:{type:'error',value:'Can not find this user', code: 0}}
        end
      end

      # Ignore Friend
      # POST: /api/v1/friends/ignore_friend
      # parameters:
      #   token               String *required
      #   friend_id           String *required
      post :ignore_friend do
        user            = User.find_by_auth_token(params[:token])
        friend_id       = params[:friend_id]        
        if user.present?
          friend = User.find(friend_id)
          user.ignore_friend(friend)
          
          {data:friend.friend_api_detail(user), message:{type:'success',value:'ignore friend', code:TimeChatNet::Application::SUCCESS_QUERY}}
        else
          {data:[], message:{type:'error',value:'Can not find this user', code: 0}}
        end
      end

      # Remove Ignore Friend
      # POST: /api/v1/friends/remove_ignore_friend
      # parameters:
      #   token               String *required
      #   friend_id           String *required
      post :remove_ignore_friend do
        user            = User.find_by_auth_token(params[:token])
        friend_id       = params[:friend_id]        
        if user.present?
          friend = User.find(friend_id)
          user.remove_ignore_friend(friend)          
          {data:friend.friend_api_detail(user), message:{type:'success',value:'remove ignore friend', code:TimeChatNet::Application::SUCCESS_QUERY}}
        else
          {data:[], message:{type:'error',value:'Can not find this user', code: 0}}
        end
      end

      # Remove Friend
      # POST: /api/v1/friends/remove_friend
      # parameters:
      #   token               String *required
      #   friend_id           String *required
      post :remove_friend do
        user            = User.find_by_auth_token(params[:token])
        friend_id       = params[:friend_id]        
        if user.present?
          friend = User.find(friend_id)
          user.remove_friend(friend)          
          {data:friend.friend_api_detail(user), message:{type:'success',value:'remove friend', code:TimeChatNet::Application::SUCCESS_QUERY}}
        else
          {data:[], message:{type:'error',value:'Can not find this user', code: 0}}
        end
      end


    end
  end
end
