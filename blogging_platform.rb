require_relative "validation.rb"
class BloggingPlatform
  attr_accessor :user_id 
  include Validation

  def initialize
    @user_id
    @blog_obj = Blog.new()
    @post_obj = Post.new(@blog_obj)
    @deshboard_obj = Deshboard.new(@blog_obj, @post_obj)
  end

  def blogging_platform(user_id, users)
    @user_id = user_id
    attempts = 0
    loop do
      puts "============================="
      puts "Please choose an option:"
      puts "1. My Dashboard"
      puts "2. Manage My Blog"
      puts "3. Manage My Post"
      puts "4. Follow a Blog"
      puts "5. Display All Posts"
      puts "6. Search Posts"
      puts "7. Comment on a Post"
      puts "8. Log Out"
      puts "============================"
      choice = get_validation("Enter your choice:", "num")
      return unless choice
      choice = choice.to_i
      case choice
      when 1
        @deshboard_obj.my_deshboard(users, user_id)
      when 2
        blog
      when 3
        post
      when 4
        @blog_obj.follow_blog(@user_id)
      when 5
        @post_obj.display_all_posts(@user_id)
      when 6
        @post_obj.search_posts(@user_id)
      when 7
        @post_obj.post_comments(@user_id) 
      when 8
        puts "Logout Success"
        break
      else
        puts "Invalid choice! Please try again later"
        attempts += 1
        if attempts >= 3
          return
        end
      end
    end
  end

  def blog
    attempts = 0
    loop do
      puts "============================="
      puts "Please choose an option:"
      puts "1. Create a Blog"
      puts "2. Publish a Blog"
      puts "3. Display My Blog"
      puts "4. Delete a Blog"
      puts "5. UPDATE Published Blog"
      puts "6. Back"
      puts "============================"
      choice = get_validation("Enter your choice:", "num")
      return unless choice
      choice = choice.to_i
      case choice
      when 1
        @blog_obj.create_blogs(@user_id)
      when 2
        @blog_obj.publish_blog(@user_id)
      when 3
        @blog_obj.display_my_blog(@user_id)
      when 4
        @blog_obj.delete_blog(@user_id)
      when 5
        @blog_obj.update_blog_title(@user_id, @post_obj)
      when 6
        return 
      else
        puts "Invalid choice! Please try again later"
        attempts += 1
        if attempts >= 3
          return
        end
      end
    end
  end
  
  def post
    attempts = 0   
    loop do
      puts "============================="
      puts "Please choose an option:"
      puts "1. Write a Post"
      puts "2. Display My Post"
      puts "3. Delete a Post"
      puts "4. Back"
      puts "============================"
      choice = get_validation("Enter your choice:", "num")
      return unless choice

      choice = choice.to_i
      case choice
      when 1
        @post_obj.create_post(@user_id)
      when 2
        @post_obj.display_my_post(@user_id)
      when 3
        @post_obj.delete_post(@user_id)
      when 4
        return
      else
        puts "Invalid choice! Please try again"
        attempts += 1
        if attempts >= 3
          return
        end
      end
    end
  end
end
