# Seeds for SeggiMeter

admin = User.find_or_create_by!(name: "admin") do |u|
  u.password = "admin"
  u.admin = true
end
admin.update!(admin: true) unless admin.admin?

user1 = User.find_or_create_by!(name: "damian") do |u|
  u.password = "damian"
  u.admin = false
end

lobby1 = Lobby.find_or_create_by!(title: "Welche Technologien begeistern dich am meisten?") do |l|
  l.user = admin
end

lobby2 = Lobby.find_or_create_by!(title: "Was verbindest du mit modernem Web Development?") do |l|
  l.user = admin
end

# Sample submissions for lobby1
words_user1 = ["Ruby", "Rails", "Hotwire"]
words_user2 = ["Ruby", "Turbo", "Stimulus"]
words_admin = ["Ruby", "Rails", "SQLite"]

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

puts "Seed-Daten erfolgreich geladen!"
puts "Admin User: 'admin' / 'admin'"
puts "Normal User: 'damian' / 'damian'"
