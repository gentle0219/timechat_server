module Endpoints
  class Accounts < Grape::API

    resource :accounts do
      # Forgot Password
      # GET: /api/v1/accounts/forgot_password
      # parameters:
      #   email:      String *required

      get :forgot_password do
        user = User.where(email:params[:email]).first
        if user.present?
          UserMailer.forgot_password(user).deliver
          {success: 'Email was sent successfully'}
        else
          {:failed => 'Cannot find your email'}
        end
      end

      desc "Get last cleaner from property"
      post :send_invite do
        
      end

      # Change Password
      # POST: /api/v1/accounts/change_password
      # parameters:
      #   token             String *required
      #   old_password      String *required
      #   new_password      String *required

      desc "Change Password"
      post :change_password do
        old_password = params[:old_password]
        new_password = params[:old_password]
        user = User.find_by_auth_token(params[:token])
        if user.present?
          if user.valid_password?(new_password)
            user.password = new_password
            user.password_confirmation = new_password
            user.save
          else
            {data:[],message:{type:'error',value:user.errors.messages,code:TimeChat::Application::ERROR_CHANGE_PASSWORD}}
          end
          {data:[],message:{type:'success',value:'Changed the password', code:TimeChat::Application::SUCCESS_CHANGE_PASSWORD}}
        else
          {data:[],message:{type:'error',value:'Can not find this user', code:TimeChat::Application::ERROR_CHANGE_PASSWORD}}
        end
      end

      # Change User name
      # POST: /api/v1/accounts/change_user_name
      # parameters:
      #   token             String *required
      #   user_name         String *required

      desc "Change user name"
      post :change_user_name do
        user_name = params[:username]
        user = User.find_by_auth_token(params[:token])
        if user.present?
          if user.valid_password?(new_password)
            user.password = new_password
            user.password_confirmation = new_password
            user.save
          else
            {data:[],message:{type:'error',value:user.errors.messages, code: 0}}  
          end
          {data:[],message:{type:'success',value:'Changed the password', code: 0}}
        else
          {data:[],message:{type:'error',value:'Can not find this user', code: 0}}
        end
      end

      # Change email
      # POST: /api/v1/accounts/change_email
      # parameters:
      #   token             String *required
      #   new_email         String *required
      post :change_email do
        new_email = params[:new_email]
        user = User.find_by_auth_token(params[:token])
        if user.present?
          if user.update_attributes(email:new_email)
            {data:[],message:{type:'success',value:'Changed the new email', code: 0}}
          else
            {data:[],message:{type:'error',value:user.errors.messages, code: 0}}
          end
        else
          {data:[],message:{type:'error',value:'Can not find this user', code: 0}}
        end
      end

      # Change avatar
      # POST: /api/v1/accounts/upload_avatar
      # parameters:
      #   token             String *required
      #   avatar            Image *required      
      post :upload_avatar do
        avatar = params[:avatar]
        user = User.find_by_auth_token(params[:token])
        if user.present?
          if user.update_attributes(avatar:avatar)
            {data:[],message:{type:'success',value:'Changed the avatar', code: 0}}
          else
            {data:[],message:{type:'error',value:user.errors.messages, code: 0}}
          end
        else
          {data:[],message:{type:'error',value:'Can not find this user', code: 0}}
        end
      end

      # Check sigined user
      # POST: /api/v1/accounts/check_token
      # parameters:
      #   token             String *required

      post :check_token do
        user = User.find_by_auth_token(params[:token])
        if user.present?
          #if (Time.now - user.last_sign_in_at) / 1.minute < 25
            user_info = {id:user.id.to_s, username:user.name,email:user.email,token:user.authentication_token,avatar:user.avatar.url}
            {data:user_info,message:{type:'success',value:'login success', code: TimeChatNet::Application::SUCCESS_LOGIN}}
          #else
          #  render :json => {data:[],message:{type:'error',value:'sigin again', code: TimeChatNet::Application::ERROR_LOGIN}}
          #end          
        else
          {data:[],message:{type:'error',value:'Can not find this user', code: 0}}
        end
      end


      # Check sigined user
      # POST: /api/v1/accounts/check_token
      # parameters:
      #   token             String *required
      post :setting do
      end

    end # end accounts
  end
end