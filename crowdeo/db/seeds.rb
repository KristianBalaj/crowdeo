# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

puts "Starting seed..."

Gender.destroy_all
ActiveRecord::Base.connection.execute('TRUNCATE events_count')

Gender.create([{ id: 0, gender_tag: "male" }, { id: 1, gender_tag: "female" }])

#Insert initial events count
ActiveRecord::Base.connection.execute("INSERT INTO events_count (rows_count) VALUES (#{Event.all.count})")

puts "Seed completed."
