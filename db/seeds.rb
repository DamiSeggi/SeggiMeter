# Seeds for SeggiMeter

admin = User.find_or_create_by!(name: "admin") do |u|
  u.password = "password1234"
  u.admin = true
end
admin.update!(admin: true) unless admin.admin?

user1 = User.find_or_create_by!(name: "damian") do |u|
  u.password = "password1234"
  u.admin = false
end

user2 = User.find_or_create_by!(name: "nico") do |u|
  u.password = "password1234"
  u.admin = false
end

lobby1 = Lobby.find_or_create_by!(title: "Which technologies inspire you the most?") do |l|
  l.user = admin
end

lobby2 = Lobby.find_or_create_by!(title: "What comes to mind when you think of modern web development?") do |l|
  l.user = admin
end

submission_seeds = {
  lobby1 => {
    admin => [ "Ruby", "Rails", "SQLite" ],   
    user1 => [ "Ruby", "Rails", "Hotwire" ],
    user2 => [ "Ruby" ]
  },
  lobby2 => {
    admin => [ "Turbo", "JavaScript", "REST" ], 
    user1 => [ "Turbo", "JavaScript" ],
    user2 => [ "Phoenix" ]
  }
}

submission_seeds.each do |lobby, user_words|
  user_words.each do |user, words|
    words.each do |word|
      Submission.find_or_create_by!(user: user, lobby: lobby, word: word)
    end
  end
end

ActivityLog.find_or_create_by!(user: admin, action: "lobby_created")
ActivityLog.find_or_create_by!(user: user1, action: "user_registered")
ActivityLog.find_or_create_by!(user: user1, action: "submitted_word")
ActivityLog.find_or_create_by!(user: user2, action: "user_registered")
ActivityLog.find_or_create_by!(user: user2, action: "submitted_word")
ActivityLog.find_or_create_by!(user: admin, action: "submitted_word")

puts "Seed data successfully loaded!"
puts "Admin User: 'admin' / 'password1234'"
puts "Normal User: 'damian' / 'password1234'"
puts "Normal User: 'nico' / 'password1234'"
