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

lobby1 = Lobby.find_or_create_by!(title: "Which technologies inspire you the most?") do |l|
  l.user = admin
end

lobby2 = Lobby.find_or_create_by!(title: "What comes to mind when you think of modern web development?") do |l|
  l.user = admin
end

# Sample submissions for lobby1
words_user1 = [ "Ruby", "Rails", "Hotwire" ]
words_user2 = [ "Ruby", "Turbo", "Stimulus" ]
words_admin = [ "Ruby", "Rails", "SQLite" ]

words_user1.each do |word|
  Submission.find_or_create_by!(user: user1, lobby: lobby1, word: word)
end

words_admin.each do |word|
  Submission.find_or_create_by!(user: admin, lobby: lobby1, word: word)
end

ActivityLog.find_or_create_by!(user: admin, action: "lobby_created")
ActivityLog.find_or_create_by!(user: user1, action: "user_registered")
ActivityLog.find_or_create_by!(user: user1, action: "submitted_word")
ActivityLog.find_or_create_by!(user: admin, action: "submitted_word")

puts "Seed data successfully loaded!"
puts "Admin User: 'admin' / 'password1234'"
puts "Normal User: 'damian' / 'password1234'"
