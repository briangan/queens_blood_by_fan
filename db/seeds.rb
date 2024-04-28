# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

puts "\nCreating users ===================================="
%w(brian jason).each do |username|
  User.find_or_create_by!(email: username + '@me.com') do |user|
    user.username = username
    user.password = 'test1234'
  end
end