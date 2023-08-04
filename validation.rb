module Validation
  def get_validation(message, condition)
    max_attempts = 3
    attempts = 1
    numeric_regex = /\A\d+(\.\d+)?\z/
    num = "num"
    str = "str"
    loop do
      puts message
      choice = gets.chomp.strip

      if choice.empty?
        if attempts >= max_attempts
          puts "No more chances...."
          return nil
        end
      end
      if num == condition
        if choice.match?(numeric_regex)
          return choice
        else
          puts "Invalid input. Please enter a numerical value."
          if attempts >= max_attempts
            return nil
          end
        end
      elsif str == condition
        return choice
      end
      attempts += 1
    end
  end

  def get_password
    a = 0
    puts "Enter your password (with special characters):"
    password = gets.chomp.strip

    while password.empty? || !password.match?(/[!@#$%^&*()_+{}\[\]:;<>,.?~\-]/)
      a += 1
      if a == 3
        return nil
      end

      puts "Enter your password (with special characters):"
      password = gets.chomp.strip
    end

    password
  end

  def get_valid_password_hidden
    puts "Enter your password (with special characters):"
    password = ""

    while char = STDIN.getch
      break if char == "\r" || char == "\n"

      if char == "\u007F" || char == "\b"
        if password.length > 0
          print "\b \b"
          password.chop!
        end
      else
        print '*'
        password += char
      end
    end

    puts
    password
  end
end
