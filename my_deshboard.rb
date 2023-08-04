require_relative "validation.rb"

class Deshboard
  attr_accessor :user_id, :users, :blog_obj, :post_obj
  include Validation

  def initialize(blog_obj, post_obj)
    @blog_obj = blog_obj
    @post_obj = post_obj
    @comments = @post_obj.comments   # (access @comments from post Class)
    @posts = @post_obj.posts         # (access @posts from post Class)
  end

  def my_deshboard(users, user_id)
    @users = users
    @user_id = user_id
    loop do
      puts "==== My Dashboard ===="
      puts "1. Change User Password"
      puts "2. Count My Blogs"
      puts "3. Count My Posts"
      puts "4. Followers"
      puts "5. Back"
      puts "============================"
      choice = get_validation("Enter your choice:", "num")
      return unless choice
      choice = choice.to_i
      case choice
      when 1
        change_password
      when 2
        count_blogs
      when 3
        count_posts
      when 4
        count_blog_followers
      when 5
        return
      else
        puts "Invalid choice. Please try again."
        attempts += 1
        if attempts >= 3
          return
        end
      end
    end
  end

  def change_password
    new_password = get_password
    return unless new_password

    @users.each do |user| # change password in users array
      if user[:username] == @user_id
        user[:password] = new_password
      end
    end
    puts "Password updated successfully!"
  end

  def count_posts
    matched_posts = @posts.select { |post| post[:user_id] == @user_id }
    puts "Total Posts: #{matched_posts.length}"
  end

  def count_blogs
    matched_blogs1 = @blog_obj.create_blog.select { |blog| blog[:user_id] == @user_id }
    matched_blogs2 = @blog_obj.published_blogs.select { |blog| blog[:user_id] == @user_id }
    total_blogs = matched_blogs1.length + matched_blogs2.length
    puts "Total Blogs: #{total_blogs}"
  end
  

  def count_blog_followers
    user_blog_followers = @blog_obj.blog_followers.select { |follower| follower[:blog_user] == @user_id }
    total_followers = user_blog_followers.length
    puts "   Blog Followers: #{total_followers}"

    user_blog_followers.each_with_index do |follower|
      puts "--------------------------------"
      puts "  Blog         : #{follower[:blog_title]}"
      puts "  Follower     : #{follower[:user_id]}"
      puts "---------------------------------"
    end
  end
end
