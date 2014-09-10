p "clear all friens relation"
User.all.each do |u|
  u.update_attributes(friend_ids:'', invited_friend_ids:'', ignored_friend_ids:'')
end

p "clear share medias"

Medium.all.each do |m|
  m.update_attributes(shared_ids:'')
end

Notification.destroy_all