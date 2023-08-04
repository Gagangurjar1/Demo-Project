require_relative "validation.rb"

class Registration
  attr_accessor :obj1, :users, :user_id
  include Validation

  def initialize()
    @users = []
    @obj1 = BloggingPlatform.new()
  end

  def register
    regex = /\A(?!\d+\z)[\w]+\z/
    username = get_validation("Enter your username", "str")
    return unless username

    username = username.downcase
    if !username.match?(regex)
      puts "Please enter a valid username! You can't create a numerical username."
      return
    end

    password = get_password
    return unless password

    user1 = @users.find { |u| u[:username] == username }
    if user1 
      puts "You already have an account! Please enter a unique username."
    else
      users = { username: username, password: password }
      @users << users
      puts "Registration successful!"
    end
  end

  def login
    username = get_validation("Enter your username", "str")
    return unless username

    password = get_valid_password_hidden
    return unless password

    user = @users.find { |u| u[:username] == username.downcase && u[:password] == password }
    if user
      puts "Login successful!"
      user_id = username
      # Call the blogging platform method in the BloggingPlatform class
      @obj1.blogging_platform(user_id, @users)
    else
      puts "Invalid username or password. Please try again."
    end
  end
end
