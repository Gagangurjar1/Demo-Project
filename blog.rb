require_relative "validation.rb"

class Blog
  attr_accessor :user_id, :published_blogs, :blog_followers, :create_blog
  include Validation

  def initialize()
    @create_blog = []
    @published_blogs = []
    @blog_followers = []
  end

  def create_blogs(user_id)
    puts "========= Creating new Blog ============="
    title = get_validation("Enter the blog url:", "str")
    return unless title
    if title.empty?
      puts "please enter valid blog title"
      return
    end
    find_unpublished_blog = find_blog_title(@create_blog, title, user_id)
    find_published_blog = find_blog_title(@published_blogs, title, user_id)
    if find_unpublished_blog || find_published_blog
      puts "You already have a blog. Please enter a unique title."
      return
    end
    new_blog = { user_id: user_id, title: title }
    @create_blog << new_blog
    puts "======== Blog created! ========"
  end

  def publish_blog(user_id)
    if @create_blog.empty?
      puts "No blogs to publish."
      return
    end
    unpublished_blogs = create_blog_validation(user_id, @create_blog) #(select current user unpublished blog )
    if unpublished_blogs.empty?
      puts "All your blogs have been published."
      return
    end
    puts "Unpublished blogs:"
    print_blog(unpublished_blogs) #call print blog method
    puts "Enter the number of the blog you want to publish:"
    selected_blog = find_blog(unpublished_blogs) #call find blog method
    if selected_blog.nil?
      return
    end
    @published_blogs << selected_blog
    @create_blog.delete(selected_blog)
    puts "Blog '#{selected_blog[:title]}' has been published!"
  end

  def display_my_blog(user_id)
    #(find current user blog )
    current_user_publish_blogs = create_blog_validation(user_id, @published_blogs)
    current_user_unpublish_blogs = create_blog_validation(user_id, @create_blog)
    if current_user_publish_blogs.empty? && current_user_unpublish_blogs.empty?
      puts "You don't have any blogs."
      return
    end
    puts "=== Published Blogs ==="
    if current_user_publish_blogs.empty?
      puts "You don't have Published Blogs."
    else
      print_blog(current_user_publish_blogs) #call print blog method
    end
    puts "=== Unpublished Blogs ==="
    if current_user_unpublish_blogs.empty?
      puts "You don't have Unpublished Blogs."
    else
      print_blog(current_user_unpublish_blogs) #call print blog method
    end
  end

  def delete_blog(user_id)
    @user_id = user_id
    attempts = 0
    loop do
      puts "----------------------"
      puts "choose an option"
      puts "1. Published Blogs"
      puts "2. Unpublished Blogs"
      puts "3. back "
      puts "-----------------------"
      choice = get_validation("Enter your choice:", "num")
      return unless choice
      choice = choice.to_i
      case choice
      when 1
        delete_blogs(@published_blogs)
      when 2
        delete_blogs(@create_blog)
      when 3
        return
      else
        puts "Invalid choice, please enter the correct number."
        attempts += 1
        if attempts >= 3
          return
        end
      end
    end
  end

  def delete_blogs(blogs)
    current_blogs = create_blog_validation(@user_id, blogs)
    if current_blogs.empty?
      puts "You don't have any blogs to delete."
      return
    end
    print_blog(current_blogs) #call print blog method
    puts "Enter the number of the blog you want to delete:"
    selected_blog = find_blog(current_blogs) #call find blog method
    if selected_blog.nil?
      return
    end
    blogs.delete(selected_blog)
    puts "Blog '#{selected_blog[:title]}' has been deleted."
  end

  def follow_blog(user_id)
    other_users_blogs = @published_blogs.select { |blog| blog[:user_id] != user_id }
    if other_users_blogs.empty?
      puts "No blogs available for follow!!!"
      return
    end
    others_users(other_users_blogs) #call users method for print blog
    puts "Enter the number of the blog you want to follow:"
    selected_blog = find_blog(other_users_blogs)
    if selected_blog.nil?
      return
    end
    blog_title = selected_blog[:title]
    blog_user = selected_blog[:user_id]
    allready_follow = @blog_followers.select { |blog| blog[:blog_title] == blog_title && blog[:user_id] == user_id }
    if allready_follow.empty?
      followers = { user_id: user_id, blog_user: blog_user, blog_title: blog_title }
      @blog_followers << followers
      puts "You are now following the blog '#{blog_title}'."
    else
      puts "You have already followed this blog."
    end
  end

  attempts = 0
  def update_blog_title(user_id, post_obj)
    loop do
      puts "----------------------"
      puts "choose an option"
      puts "1.UPDATE Unpublished Blogs "
      puts "2.UPDATE Published Blogs "
      puts "3. back "
      puts "-----------------------"
      choice = get_validation("Enter your choice:", "num")
      return unless choice
      choice = choice.to_i
      case choice
      when 1
        unpublished_blogs_update(user_id)  
      when 2
        published_blogs_update(user_id, post_obj)
      when 3
        return
      else
        puts "Invalid choice, please enter the correct number."
        attempts += 1
        if attempts >= max_attempts
          return
        end 
      end
    end
  end

  def unpublished_blogs_update(user_id)
    selected_blog = blog_update(user_id, @create_blog)     #call blog update method
    if selected_blog.nil?                             # for select  current user blog
      return
    end
    new_title = get_validation("Enter new blog title", "str")
    return unless new_title 
    if new_title.nil?
      return
    end
    old_title = selected_blog[:title]
    @create_blog.each do |blog|
      if blog[:title] == old_title && blog[:user_id] == user_id
        blog[:title] = new_title
      end
    end
  end

  def published_blogs_update(user_id, post_obj)
    selected_blog = blog_update(user_id, @published_blogs)   #call blog update method
    if selected_blog.nil?                                 # for select  current user blog
      return 
    end
    new_title = get_validation("Enter new blog title", "str")
    return unless new_title
    if new_title.nil?
      return 
    end
     
    old_title = selected_blog[:title]
    posts = post_obj.posts # change blog title in posts array
    posts.each do |post|
      if post[:blog_title] == old_title && post[:user_id] == user_id
        post[:blog_title] = new_title
      end
    end
    update_blog_support(old_title, new_title, user_id) #call update blog support methods
  end 

  # FOR VALIDATION METHODS

  def update_blog_support(old_title, new_title, user_id)
    @published_blogs.each do |blog|
      if blog[:title] == old_title && blog[:user_id] == user_id # change blog title in published array
        blog[:title] = new_title
      end
    end
    @blog_followers.each do |follower| # change blog title in blog followers array
      if follower[:blog_title] == old_title && follower[:user_id] == user_id
        follower[:blog_title] = new_title
      end
      if follower[:blog_title] == old_title && follower[:blog_user] == user_id
        follower[:blog_title] = new_title
      end
    end
    puts "Blog title '#{old_title}' has been updated to '#{new_title}'."
  end

  def blog_update(user_id, blogs)
    current_publish_blogs = create_blog_validation(user_id, blogs) #select current user blog
    if current_publish_blogs.empty?
      puts "You don't have any published blogs to update."
      return nil
    end
    print_blog(current_publish_blogs) #call print blog methods
    puts "Enter the number of the blog you want to update:"
    selected_blog = find_blog(current_publish_blogs)
    if selected_blog.nil?
      return nil
    end
    return selected_blog
  end  

  def print_blog(blogs)
    blogs.each_with_index do |blog, index|
      puts "#{index + 1}. #{blog[:title]}"
    end
  end

  def find_blog(blogs)
    choice = gets.chomp.to_i
    if choice.positive? && choice <= blogs.length
      selected_blog = blogs[choice - 1]
      return selected_blog
    else
      puts "Invalid choice."
      return nil
    end
  end

  # (select current user blog )
  def create_blog_validation(user_id, blogs)
    blog = blogs.select { |blog| blog[:user_id] == user_id }
    return blog
  end

  def find_blog_title(blogs, title, user_id)
    blog = blogs.find { |blog| blog[:title] == title && blog[:user_id] == user_id }
  end

  def others_users(blogs)
    blogs.each_with_index do |blog, index|
      puts "#{index + 1}. : #{blog[:title]} : #{blog[:user_id]}"
    end
  end
end
