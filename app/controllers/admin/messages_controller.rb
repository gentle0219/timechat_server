class Admin::MessagesController < ApplicationController
  layout 'admin'
  before_filter :authenticate_admin

  def index
    if current_user.is_admin?
      @members = User.all
    else
      @members = current_user.members
    end
    respond_to do |format|
      format.html
      format.json { render json: @members }
    end
  end

  def inbox
    @sender = current_user
    @conversations = current_user.conversations.paginate(page: params[:page], :per_page => 15)
  end

  def new
    @message = Message.new
    if current_user.is_admin?
      @properties = Property.all
    else
      @properties = current_user.properties
    end
  end
  def create
    case params[:msg_option]
    when "0"
      receiver = Property.find(params[:property]).user
      subject = "Send Single Property Message"
      message = Message.new(subject:subject, body:params[:body], sender:current_user, receiver:receiver, level:Message::LEVELS[2])
      destination = [receiver.device_id]
      data = {key:"#{current_user.name} sent you message '#{params[:body]}'"}
      notif = GCM.send_notification( destination, data )
      message.save
      Conversation.add_message(receiver, current_user, message)
    when "1"
      receivers = Property.all.map(&:user)      
      subject = "Send All Property Message"
      send_messages(receivers, current_user, subject, params[:body])
    when "2"      
      receivers = current_user.is_admin? ? User.cleaners : current_user.members.cleaners
      subject = "Send All Cleaners Message"
      send_messages(receivers, current_user, subject, params[:body])

    when "3"
      receivers = current_user.is_admin? ? User.inspectors : current_user.members.inspectors
      subject = "Send All Inspectors Message"
      send_messages(receivers, current_user, subject, params[:body])
    end
    redirect_to action: :index
    flash[:notice] = "Sent message"
  end

  def edit
  end
  def update
  end

  def destroy
    @conversation = Conversation.find(params[:id])
    @conversation.destroy
    redirect_to action: :inbox
  end

  def show    
    user = User.find(params[:id])
    @sender = user
    @conversations = user.conversations.paginate(page: params[:page], :per_page => 15)
    respond_to do |format|
      format.html
      format.json { render json: @messages}
    end
  end

  def send_messages(receivers, sender, subject, body)    
    receivers.each do |recv|
      message = Message.new(subject:subject, body:body, sender:sender, receiver:recv, level:Message::LEVELS[2])
      destination = [recv.device_id]
      data = {key:"#{current_user.name} sent you message '#{params[:body]}'"}
      notif = GCM.send_notification( destination, data )
      message.save
      Conversation.add_message(recv, current_user, message)
    end
  end

  def message_list
    @sender = params[:user_id].present? ? User.find(params[:user_id]) : current_user
    @conversation = Conversation.find(params[:id])
  end
end