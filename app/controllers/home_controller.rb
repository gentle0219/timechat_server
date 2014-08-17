class HomeController < ApplicationController
  
  protect_from_forgery with: :exception
  skip_before_filter :verify_authenticity_token

  def index
  end


  def sign_up
    email               = params[:email]
    password            = params[:password]
    user_id             = params[:user_id]
    user_name           = params[:user_name]
    dev_id              = params[:dev_id]    
    social_type         = params[:social_type]
    remote_avatar_url   = params[:avatar]
    time_zone           = params[:timezone]
    status              = false

    if email.blank? && user_id.blank?
      render :json => {failed: 'please check again account information'}, :status => 401
    else
      user          = User.new
      case social_type
      when User::SOCIAL_TYPES[0]    # if social type is email
        user = User.new
        status = User.update_attributes(email:email,password:password,password_confirmation:password,name:user_name)      
      when User::SOCIAL_TYPES[1]    # if social type is facebook
        user = User.where(email:email).first
        if user.present?
          status = user.update_attributes(social_id:user_id, name:user_name, time_zone:time_zone, remote_avatar_url:remote_avatar_url)
        else
          password = (0...8).map{(65+rand(26)).chr}.join
          user = User.new
          status = user.update_attributes(email:email,password:password,password_confirmation:password,social_type:social_type,social_id:user_id, name:user_name, time_zone:time_zone, remote_avatar_url:remote_avatar_url)
        end      

      when User::SOCIAL_TYPES[2]    # if social type is twitter
        email = user_id + "@timechat.com"
        user = User.where(email:email).first
        if user.present?
          status = user.update_attributes(social_id:user_id, name:user_name)
        else
          user = User.new
          password = (0...8).map{(65+rand(26)).chr}.join
          status = user.update_attributes(email:email,password:password,password_confirmation:password,social_type:social_type,social_id:user_id, name:user_name)
        end

      when User::SOCIAL_TYPES[3]    # if social type is google        
        user = User.where(email:email).first
        if user.present?
          status = user.update_attributes(social_id:user_id, name:user_name)
        else
          user = User.new
          password = (0...8).map{(65+rand(26)).chr}.join
          status = user.update_attributes(email:email,password:password,password_confirmation:password,social_type:social_type,social_id:user_id, name:user_name)
        end
        
      end

      if status == false
        render :json => {:failed => user.errors.messages}
      else        
        user.devices.create_by_device_id(dev_id)
        user = sign_in( :user, user )
        user_info = {id:user.id.to_s, username:user.name,email:user.email,token:user.authentication_token,avatar:user.avatar.url}

        render :json => {data:user_info,message:{type:'success',value:'login success', code: TimeChatNet::Application::SUCCESS_LOGIN}}
      end
    end     
  end
  
  def create_session
    email           = params[:email]
    password        = params[:password]
    dev_id          = params[:dev_id]
    
    resource = User.find_for_database_authentication( :email => email )
    
    if resource.nil?
      render :json => {failed:'No Such User'}, :status => 401
    else      
      if resource.valid_password?( password )
        resource.devices.create_by_device_id(dev_id)
         
        user = sign_in(:user, resource)        
        user_info={id:resource.id.to_s, username:resource.name,email:resource.email,token:resource.authentication_token,avatar:user.avatar.url}
        
        render :json => {data:user_info,message:{type:'success',value:'login success', code: TimeChatNet::Application::SUCCESS_LOGIN}}
      else
        render :json => {data:user_info,message:{type:'error',value:'signin failed', code: TimeChatNet::Application::ERROR_LOGIN}}
      end
    end
   end

   def delete_session
    if params[:auth_token].present?
      resource = User.find_by_auth_token(params[:auth_token])
    end
    
    if resource.nil?
      render :json => {data:user_info,message:{type:'error',value:'No Such User', code: TimeChatNet::Application::ERROR_LOGIN}}
    else
      sign_out(resource)      
      render :json => {data:user_info,message:{type:'success',value:'Success sign out', code: TimeChatNet::Application::SUCCESS_LOGOUT}}
    end
  end
  

end
