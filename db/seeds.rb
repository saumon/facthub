# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

Admin.find_or_create_by!(email: "admin@example.com") do |admin|
  admin.password = "password"
end

[
  "Honey never spoils. Archaeologists have found 3,000-year-old honey in Egyptian tombs that was still perfectly edible.",
  "A group of flamingos is called a flamboyance.",
  "The shortest war in history was between Britain and Zanzibar in 1896 — it lasted between 38 and 45 minutes.",
  "Bananas are berries, but strawberries are not.",
  "Octopuses have three hearts and blue blood."
].each do |body|
  Fact.find_or_create_by!(body: body)
end
