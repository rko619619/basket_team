unless Admin.where(email: "sasha@esasha.com").exists?
  Admin.create!(email: "sasha@sasha.com", password: "sasha@sasha.com", password_confirmation: "sasha@sasha.com")
end
