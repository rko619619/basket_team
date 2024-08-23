unless AdminUser.where(email: "sasha@esasha.com").exists?
  AdminUser.create!(email: "sasha@sasha.com", password: "sasha", password_confirmation: "sasha")
end
