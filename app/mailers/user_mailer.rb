class UserMailer < ActionMailer::Base
  include Devise::Mailers::Helpers
  default from: "support@timechat.com.au"

  def welcome(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome')
  end

  def invite_friend(user, friend)
    @user = user
    @friend = friend
    mail(to: @user.email, subject: 'Invite Friend')
  end

  def accept_friend(user, friend)
    @user = user
    @friend = friend
    mail(to: @user.email, subject: 'Acceted Friend')
  end

  def decline_friend(user, friend)
    @user = user
    @friend = friend
    mail(to: @user.email, subject: 'Declined Friend')
  end

  def ignore_friend(user, friend)
    @user = user
    @friend = friend
    mail(to: @user.email, subject: 'Ignored Friend')
  end

  def remove_friend(user,friend)
    @user = user
    @friend = friend
    mail(to: @user.email, subject: 'Removed Friend')
  end
end
