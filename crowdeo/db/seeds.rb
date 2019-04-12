# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

EventAttendance.destroy_all
Event.destroy_all
User.destroy_all

users_hash_arr = []

for i in 0..100
  users_hash_arr.push({ nick_name: "nick#{i}", email: "nick#{i}@email.com", password: "password" })
end

User.create(users_hash_arr)

Event.create({
               name: "Event 1",
               description: "description of the event 1.",
               start_date: "2017-03-06",
               end_date: "2017-03-07",
               author_id: User.first.id
             })