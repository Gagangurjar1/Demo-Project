require_relative "blogging_platform.rb"
require_relative "post.rb"
require_relative "blog.rb"
require_relative "registration"
require_relative "my_deshboard.rb"
require_relative "validation.rb"
require 'io/console'

class Main
  include Validation
  def initialize
    @obj = Registration.new( ) 
  end
    
  def start
    attempts = 0
    loop do
      puts "========= Welcome to MyBlog.com  ==================="
      puts "Please choose an option:"
      puts "1. Register an Account"
      puts "2. Log In"
      puts "3. Exit"
      puts "===================================================="
      choice = get_validation("Enter your choice:","num")
      return unless choice
      choice = choice.to_i
      case choice
      when 1
        @obj.register
      when 2
        @obj.login
      when 3
        exit
      else
        puts "Invalid choice, please enter correct number."
        attempts += 1
        if attempts >= 3
          return
        end
      end
    end
  end
end 

mainclass_obj = Main.new()
mainclass_obj.start
