# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

puts "Starting seed..."

EventAttendance.destroy_all
Event.destroy_all
User.destroy_all

puts "All tables destroyed..."
puts "Creating users..."

start_time = Time.now

users_hash_arr = []

for i in 0..100
  users_hash_arr.push({ nick_name: "nick#{i}", email: "nick#{i}@email.com", password: "password" })
end

User.create(users_hash_arr)

puts "Users created, time elapsed: #{Time.now - start_time} seconds"
puts "Creating events..."

start_time = Time.now

events_hash_arr = []
all_users_arr = User.all.to_a

for i in 0..10000
  events_hash_arr.push({
                           name: "Event#{i}",
                           description: "description of event #{i}.",
                           start_date: "2017-03-06",
                           end_date: "2017-03-07",
                           author_id: all_users_arr[rand(0..(all_users_arr.length - 1))].id })
end

Event.create(events_hash_arr)

puts "Events created, time elapsed: #{Time.now - start_time} seconds"