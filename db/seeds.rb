# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

p "clear all friens relation"
User.all.each do |u|
  u.update_attributes(friend_ids:'', invited_friend_ids:'', ignored_friend_ids:'')
end

p "clear share medias"

Medium.all.each do |m|
  m.update_attributes(shared_ids:'')
end

Notification.destroy_all