require 'faker'

10.times do
  # Create a list with a random name
  list = List.create(name: Faker::Lorem.words(number: 2).join(' ').titleize)

  # Create a random number of tasks (5 to 15) for each list
  rand(5..15).times do
    list.tasks.create(
      name: Faker::Lorem.sentence(word_count: 3).chop, # Random name
      description: Faker::Lorem.paragraph(sentence_count: 2), # Random description
      deadline: Faker::Time.between(from: DateTime.now, to: DateTime.now + 30) # Random deadline within 30 days
    )
  end
end

puts 'Seed data created successfully!'
