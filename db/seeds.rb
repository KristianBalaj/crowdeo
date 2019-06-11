# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

EventsGenderFilter.destroy_all
EventAttendance.destroy_all
User.destroy_all
Event.destroy_all
Gender.destroy_all

puts 'Creating genders'
Gender.create([{ id: 0, gender_tag: "male" }, { id: 1, gender_tag: "female" }])

# puts 'Creating users'
# users_to_add = []
#
# (0..10).each do |id|
#   users_to_add.push({id: id, nick_name: "nick#{id}", email: "email#{id}@mail.com", password: "password" , gender_id: rand(0..1)})
# end
#
# User.create(users_to_add) do |u|
#   unless u.valid?
#     puts "user not created, ABORT!"
#     return
#   end
# end

puts "Seed completed."
