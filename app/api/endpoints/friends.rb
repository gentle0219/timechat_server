module Endpoints
  class Friends < Grape::API

    resource :friends do

      # Get Friend List
      # GET: /api/v1/friends
      # parameters:
      #   token       String *required
      
      get do
        user = User.find_by_auth_token(params[:token])
        if user.present?
          friends = user.friends.map{|f| {id:f.id,name:f.name}}
          {data:friends,message:{type:'success',value:'Get friend list', code: 0}}
        else
          {data:[],message:{type:'error',value:'Can not find this user', code: 0}}
        end
      end

      # Get Friend Info
      # GET: /api/v1/friends/friend_info
      # parameters:
      #   token               String *required      
      get :friend_info do
      end

      # Get Search Friend
      # GET: /api/v1/friends/search_friend
      # parameters:
      #   token               String *required
      #   emails              String *required  string that splitted by comma
      get :search_friends do        
        user = User.find_by_auth_token(params[:token])
        if user.present?
          friends = user.friends.in(email:emails.split(","))
          friend_info = friends.map{|f| {id:f.id.to_s, email:f.email, debug:TimeChat::Application::DEBUG}}
          {data:friend_info, message:{type:'success',value:'Success query', code: TimeChat::Application::SUCCESS_QUERY}}
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
        user = User.find_by_auth_token(params[:token])
        if user.present?
          friend = User.where(email:email).first
          user.add_friend(friend)
          {data:{id:friend.id,username:friend.name,avatar:friend.avatar.url,email:friend.email,code:TimeChat::Application::USER_REGISTERED, debug: "User registred in system"}, message:{type:'success',value:'Added new friend', code: TimeChat::Application::SUCCESS_QUERY}}
        else
          {data:[], message:{type:'error',value:'Can not find this user', code: TimeChat::Application::USER_UNREGISTERED}}
        end
      end

      # Accept Friend
      # POST: /api/v1/friends/accept_friend
      # parameters:
      #   token               String *required
      #   friend_id           String *required
      post :accept_friend do
        user = User.find_by_auth_token(params[:token])
        if user.present?
          friend = User.where(id:friend_id).first          
          user.accept_friend(friend)
          user.add_friend(friend)
          {data:{id:friend.id,name:friend.name,avatar:friend.avatar.url}, message:{type:'success',value:'Added new friend', code: 0}}
        else
          {data:[], message:{type:'error',value:'Can not find this user', code: 0}}
        end
      end
      
      # Decline Friend
      # POST: /api/v1/friends/decline_friend
      # parameters:
      #   token               String *required
      #   friend_id           String *required
      post :decline_friend do
        user = User.find_by_auth_token(params[:token])
        if user.present?
          friend = User.where(id:friend_id).first          
          user.decline_friend(friend)
          user.add_friend(friend)
          {data:{id:friend.id,name:friend.name,avatar:friend.avatar.url}, message:{type:'success',value:'Added new friend', code: 0}}
        else
          {data:[], message:{type:'error',value:'Can not find this user', code: 0}}
        end
      end


    end
  end
end
