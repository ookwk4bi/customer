# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
26.times do |index|
  Company.create(name: "Eマーケティング研究所", address: "東京都渋谷区道玄坂1-19-11", url: "https://emarketinglab.info", user_id: "2")
end