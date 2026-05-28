namespace :users do
  desc "Set a user as admin by email. Usage: rails users:make_admin EMAIL=user@example.com"
  task make_admin: :environment do
    email = ENV["EMAIL"]

    if email.blank?
      puts "Please provide an email. Usage: rails users:make_admin EMAIL=user@example.com"
      next
    end

    user = User.find_by(email_address: email)

    if user.nil?
      puts "No user found with email: #{email}"
      next
    end

    user.update!(role: "admin")
    puts "#{user.name} (#{user.email_address}) is now an admin."
  end
end