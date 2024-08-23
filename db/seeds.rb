Admin.find_or_create_by(email: 'sasha@sasha.com') do |user|
  user.password = "sasha@sasha.com"
end
