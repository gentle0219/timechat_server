class HomeController < ApplicationController
  
  protect_from_forgery with: :exception
  skip_before_filter :verify_authenticity_token

  def index
    @user = current_user if current_user.present?
  end


  def sign_up
    email               = params[:email].present? ? params[:email].downcase : ""
    password            = params[:password]
    user_id             = params[:user_id]
    user_name           = params[:username]
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
        status = user.update_attributes(email:email,password:password,password_confirmation:password,name:user_name, time_zone:time_zone)        
      when User::SOCIAL_TYPES[1]    # if social type is facebook
        user = User.where(email:email).first
        if user.present?
          status = user.update_attributes(social_id:user_id, time_zone:time_zone, remote_avatar_url:remote_avatar_url)
        else
          password = (0...8).map{(65+rand(26)).chr}.join
          user = User.new
          status = user.update_attributes(email:email,password:password,password_confirmation:password,social_type:social_type,social_id:user_id, name:user_name, time_zone:time_zone, remote_avatar_url:remote_avatar_url)
          # user.send_notification_to_all_users
        end      

      when User::SOCIAL_TYPES[2]    # if social type is twitter
        email = user_id + "@timechat.com"
        user = User.where(email:email).first
        if user.present?
          status = user.update_attributes(social_id:user_id)
        else
          user = User.new
          password = (0...8).map{(65+rand(26)).chr}.join
          status = user.update_attributes(email:email,password:password,password_confirmation:password,social_type:social_type,social_id:user_id, name:user_name)
          # user.send_notification_to_all_users
        end

      when User::SOCIAL_TYPES[3]    # if social type is google        
        user = User.where(email:email).first
        if user.present?
          status = user.update_attributes(social_id:user_id)          
        else
          user = User.new
          password = (0...8).map{(65+rand(26)).chr}.join
          status = user.update_attributes(email:email,password:password,password_confirmation:password,social_type:social_type,social_id:user_id, name:user_name)
          # user.send_notification_to_all_users
        end        
      end

      if status == false
        msg = user.errors.full_messages.first
        # msg = msg.gsub('name', 'username').gsub('taken', 'existed').gsub(' is ', ' has ')
        msg = "This account has been already registered"
        render :json => {data:[],message:{type:'error',value:msg.capitalize, code: TimeChatNet::Application::ERROR_LOGIN}}
      else
        devices = Device.where(dev_id:dev_id)
        devices.destroy_all
        Device.create_by_device_id(dev_id, user)
        user = sign_in( :user, user )

        if social_type == User::SOCIAL_TYPES[0]          
          user_temp = UserTempNotification.where(email:email).first
          if user_temp.present?
            user_temp.user.add_friend(user)
            user_temp.destroy
          end
        end

        user_info = {id:user.id.to_s, username:user.name,email:user.email,token:user.authentication_token,avatar:user.avatar_url}
        setting   = {push_enable:user.push_enable,sound_enable:user.sound_enable,auto_accept_friend:user.auto_accept_friend,auto_notify_friend:user.auto_notify_friend, theme_type:user.theme_type, push_sound:user.push_sound}
        if social_type == User::SOCIAL_TYPES[0]
          # user.send_notification_to_all_users
          UserMailer.welcome(user).deliver
        end
        render :json => {data:{user_info:user_info,setting:setting},message:{type:'success',value:'Signed up successfully', code: TimeChatNet::Application::SUCCESS_LOGIN}}
      end
    end     
  end
  
  def create_session
    email           = params[:email].strip
    password        = params[:password]
    dev_id          = params[:dev_id]
    timezone        = params[:timezone]

    user = User.where({:email=>/^#{email.downcase}$/i}).first if email.include?("@")
    unless user.present?
      user = User.where({:name=>/^#{email.downcase}$/i}).first
    end
    resource = user
    # resource = User.find_for_database_authentication(:email => email)
    
    if resource.nil?
      render :json => {data:[],message:{type:'error',value:"#{email} doesn't exist. Please register", code: TimeChatNet::Application::ERROR_LOGIN}}
    else
      
      if resource.valid_password?(password)
        devices = Device.where(dev_id:dev_id)
        devices.destroy_all
        Device.create_by_device_id(dev_id,resource)
        user = sign_in(:user, resource)
        resource.update_attributes(time_zone:timezone, last_sign_in_at:Time.now, user_status: 1)
        user_info = { id:resource.id.to_s, username:resource.name,email:resource.email,token:resource.authentication_token,avatar:resource.avatar_url}
        setting   = { push_enable:resource.push_enable,sound_enable:resource.sound_enable,auto_accept_friend:resource.auto_accept_friend,auto_notify_friend:resource.auto_notify_friend, theme_type:resource.theme_type,push_sound:resource.push_sound}
        render :json => {data:{user_info:user_info, setting:setting},message:{type:'success',value:'login success', code: TimeChatNet::Application::SUCCESS_LOGIN}}
      else
        render :json => {data:[],message:{type:'error',value:'Password is incorrect', code: TimeChatNet::Application::ERROR_LOGIN}}
      end
    end
   end

   def delete_session
    if params[:token].present?
      resource = User.find_by_auth_token(params[:token])
    end
    
    if resource.nil?
      render :json => {data:[],message:{type:'error',value:'No Such User', code: TimeChatNet::Application::ERROR_LOGIN}}
    else
      resource.update_attributes(user_status: 1)
      sign_out(resource)
      render :json => {data:[],message:{type:'success',value:'Success sign out', code: TimeChatNet::Application::SUCCESS_LOGOUT}}
    end
  end
  
  def destroy
    user = User.find(params[:id])
    user.destroy
    redirect_to action: :index
  end  

end
