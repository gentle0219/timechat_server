# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

p ">>>>>>>>>  start creating categories"
root = Category.create_by_name('Bathroom', 1)
root.create_child('Toilet',1)
root.create_child('Sink',2)
root.create_child('Bathub',3)
root.create_child('Lights',4)
root.create_child('Other',5)
root = Category.create_by_name('Kitchen', 2)
root.create_child('Dishwasher',1)
root.create_child('Sink',2)
root.create_child('Cabinets',2)
root.create_child('Water / Plumbing',4)
root.create_child('Oven',5)
root.create_child('Other',6)
root = Category.create_by_name('Electrical / Entertainment', 3)
root.create_child('TV',1)
root.create_child('Internet',2)
root.create_child('Phone',3)
root.create_child('Light Bulb',1)
p ">>>>>>>>>  end creating categories"
