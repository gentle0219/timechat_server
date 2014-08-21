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
        new_password = params[:new_password]
        user = User.find_by_auth_token(params[:token])
        if user.present?
          if user.valid_password?(old_password)
            user.password = new_password
            user.password_confirmation = new_password
            if user.save
              {data:[],message:{type:'success',value:'Changed the password', code:TimeChatNet::Application::SUCCESS_CHANGE_PASSWORD}}
            else
              {data:user.errors.messages,message:{type:'error',value:'Can not changed the password', code:TimeChatNet::Application::SUCCESS_CHANGE_PASSWORD}}
            end
          else
            {data:[],message:{type:'error',value:user.errors.messages,code:TimeChatNet::Application::ERROR_CHANGE_PASSWORD}}
          end          
        else
          {data:[],message:{type:'error',value:'Can not find this user', code:TimeChatNet::Application::ERROR_CHANGE_PASSWORD}}
        end
      end

      # Change User name
      # POST: /api/v1/accounts/change_user_name
      # parameters:
      #   token             String *required
      #   user_name          String *required

      desc "Change user name"
      post :change_user_name do
        user_name = params[:username]
        user = User.find_by_auth_token(params[:token])
        if user.present?
          user.update_attribute(:name, user_name)
          {data:[],message:{type:'success',value:'Changed the user name', code: TimeChatNet::Application::SUCCESS_QUERY}}
        else
          {data:[],message:{type:'error',value:'Can not find this user', code: TimeChatNet::Application::ERROR_QUERY}}
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
            {data:[],message:{type:'success',value:'Changed the new email', code: TimeChatNet::Application::SUCCESS_REGISTERED_PLEASE_CONFIRM_YOUR_EMAIL}}
          else
            {data:[],message:{type:'error',value:user.errors.messages, code: TimeChatNet::Application::ERROR_CHANGE_EMAIL}}
          end
        else
          {data:[],message:{type:'error',value:'Can not find this user', code: TimeChatNet::Application::ERROR_QUERY}}
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
            {data:[],message:{type:'success',value:'Changed the avatar', code: TimeChatNet::Application::SUCCESS_QUERY}}
          else
            {data:[],message:{type:'error',value:user.errors.messages, code: TimeChatNet::Application::ERROR_QUERY}}
          end
        else
          {data:[],message:{type:'error',value:'Can not find this user', code: TimeChatNet::Application::ERROR_LOGIN}}
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


      # Push setup
      # POST: /api/v1/accounts/push_setting
      # parameters:
      #   token             String *required
      #   push_enable       String 
      #   sound_enable      String
      post :push_setting do
        push_enable = params[:push_enable] == '1' ? true : false
        sound_enable = params[:sound_enable] == '1' ? true : false
        user = User.find_by_auth_token(params[:token])
        if user.present?
          if user.update_attributes(push_enable:push_enable, sound_enable:sound_enable)
            {data:[], message:{type:'success',value:'Push setting', code: TimeChatNet::Application::SUCCESS_QUERY}}
          else
            {data:[], message:{type:'error',value:'Can not push setting', code: TimeChatNet::Application::ERROR_QUERY}}  
          end
        else
          {data:[], message:{type:'error',value:'Can not find this user', code: TimeChatNet::Application::ERROR_LOGIN}}
        end
      end

      # Get Push Setup
      # GET: /api/v1/accounts/push_setting
      # parameters:
      #   token             String *required
      get :push_setting do
        user = User.find_by_auth_token(params[:token])
        if user.present?
          {data:{push_enable:user.push_enable,sound_enable:user.sound_enable},message:{type:'success',value:'Push setting', code: TimeChatNet::Application::SUCCESS_QUERY}}  
        else
          {data:[],message:{type:'error',value:'Can not find this user', code: TimeChatNet::Application::ERROR_LOGIN}}
        end
      end

    end # end accounts
  end
end