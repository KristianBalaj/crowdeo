# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# EventsGenderFilter.destroy_all
# EventAttendance.destroy_all
# User.destroy_all
# Event.destroy_all
# Gender.destroy_all
def get_categories_names
  search_html = open('https://www.meetup.com/find/').read
  doc = Nokogiri::HTML(search_html)

  categories = doc.css('ul#simple-criteria > li > ul > li')
  result = []
  categories.each_with_index do |category, id|
    if id > 1
      result.push category.text.delete!("\n").strip
    end
  end
  return result
end

puts 'Seeding DB'

puts 'Creating missing genders'
genders_to_add = [{ id: 0, gender_tag: "male" }, { id: 1, gender_tag: "female" }]

genders_to_add.each do |g|
  unless Gender.find_by(id: g[:id])
    Gender.create(g)
  end
end

puts 'Creating missing categories'
get_categories_names.each_with_index do |category_name, id|
  unless Category.find_by(id: id)
    Category.create({id: id, name: category_name})
  end
end

# Gender.create([{ id: 0, gender_tag: "male" }, { id: 1, gender_tag: "female" }])

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
