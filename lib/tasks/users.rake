namespace :users do
  desc "Set a user as admin by email. Usage: rake users:set_admin EMAIL=user@example.com"
  task set_admin: :environment do
    email = ENV['EMAIL']

    if email.blank?
      puts "Please provide an email. Usage: rake users:set_admin EMAIL=user@example.com"
      exit
    end

    user = User.find_by(email_address: email)

    if user.nil?
      puts "No user found with email: #{email}"
      exit
    end

    user.update!(role: 'admin')
    puts "User '#{user.name}' (#{user.email_address}) is now an admin."
  end
end