require_relative "validation.rb"

class Post
  attr_accessor :comments, :posts
  include Validation

  def initialize(blog_obj)
    @blog_obj = blog_obj
    @published_blogs = @blog_obj.published_blogs
    @posts = []
    @comments = []
  end

  def create_post(user_id)           # call post create validation method for select blog
    selected_blog = post_create_val(user_id)
    if selected_blog.nil?
      return
    end 
    puts "-------------------------------------"
    post_title = get_validation("Enter the post title: ", "str")
    return unless post_title
    if post_title.empty?
      puts "please enter valid post title"
      return
    end 
    post_content = get_validation("Enter the post content:", "str")
    return unless post_content
    if post_content.empty?
      puts "please enter valid post content"
      return
    end 
    blog_title = selected_blog[:title]
    new_post = { blog_title: blog_title, user_id: user_id, post_title: post_title, post_content: post_content }
    @posts << new_post
    puts "Post '#{post_title}' has been created in the blog '#{blog_title}'."
  end

  def display_my_post(user_id)
    posts_selected = my_posts(user_id)  #call mypost method for select post
    if posts_selected.nil?
      return
    end
    if posts_selected.empty?
      puts "No posts available for selected blog"
      return
    end
    post_view(posts_selected)       #call view post method for view post
  end

  def delete_post(user_id)
    posts_selected = my_posts(user_id)  # for select post
    if posts_selected.nil?
      return
    end
    if posts_selected.empty?
      puts "No posts for the selected blog"
      return
    end
    puts "=== Posts ==="
    posts_selected.each_with_index do |post, index|
      puts "#{index + 1}. #{post[:post_title]}"
    end
    puts "Enter the number of the post you want to delete:"
    selected_post = @blog_obj.find_blog(posts_selected) # call find blog for finding blog
    if selected_post.nil?
      return
    end
    @posts.delete(selected_post)
    puts "Post '#{selected_post[:post_title]}' has been deleted"
  end

  def display_all_posts(user_id)
    attempts = 0
    loop do
      puts "----------------------"
      puts "choose an option"
      puts "1. My Blog Posts "
      puts "2. Other Blog Posts"
      puts "3. back "
      puts "-----------------------"
      choice = get_validation("Enter your choice:", "num")
      return unless choice
      choice = choice.to_i
      case choice
      when 1
        display_my_post(user_id)
      when 2
        other_posts(user_id)
      when 3
        return
      else
        puts "Invalid choice"
        attempts += 1
        if attempts >= 3
          return
        end
      end 
    end 
  end 

  def other_posts(user_id)
    followed_blogs = @blog_obj.blog_followers.select { |blog| blog[:user_id] == user_id }
    if followed_blogs.empty?
      puts "You have not followed any blogs."
    else
      puts "=== Blogs ==="
      followed_blogs.each_with_index do |blog, index|
        puts "#{index + 1}. #{blog[:blog_title]} ::: #{blog[:blog_user]}"
      end
      puts "Enter the number of the blog you want to view posts:"
      selected_blog = @blog_obj.find_blog(followed_blogs)
      if selected_blog.nil?
        return
      end
      posts_selected = @posts.select { |post| post[:blog_title] == selected_blog[:blog_title] }
      if posts_selected.empty?
        puts "No posts available for selected blog!"
        return
      end
      post_view(posts_selected)
    end
  end

  def search_posts(user_id)
    puts "-----------------------------------------------------------"
    search_character = get_validation("Enter a character to search for posts:", "str")
    return unless search_character
    if search_character.empty?
      puts "Enter valid charecter"
      return
    end      
    search_character = search_character.downcase
    found_posts = searching_code(search_character, user_id) #call searching method

    user_posts = @posts.select { |post| post[:user_id] == user_id }
    user_posts.each do |post|
      if post[:post_title].downcase.include?(search_character)
        found_posts << { blog_title: post[:blog_title], username: user_id, post_title: post[:post_title], post_content: post[:post_content] }
      end
    end
    if found_posts.empty?
      puts "No posts found with the given character in the post title."
    else
      puts "=== Found Posts ==="
      post_view(found_posts)
    end
  end

  def post_comments(user_id)             
    followed_blogs = @blog_obj.blog_followers.select { |blog| blog[:user_id] == user_id }
    user_posts = @posts.select { |post| post[:user_id] == user_id }
    puts "=========  Posts============ ==="
    blog_posts = []
    followed_blogs.each do |blog|
      blog_posts.concat(@posts.select { |post| post[:blog_title] == blog[:blog_title] })
    end
    all_posts = blog_posts + user_posts
    all_posts.each_with_index do |post, index|
      puts "#{index + 1}. #{post[:post_title]}"
    end
    if all_posts.empty?
      puts "No posts available for commenting."
      return
    end
    puts "Enter the number of the post you want to comment on:"
    selected_post = @blog_obj.find_blog(all_posts)  # call find blog method
    if selected_post.nil?
      return
    end
    for_comments(selected_post, user_id)   #call for_comments method
  end

  # FOR VALIDATION
  def post_create_val(user_id)
    current_user_blog = @blog_obj.create_blog_validation(user_id, @published_blogs)
    if current_user_blog.empty?
      puts "You don't have any published blogs to create a post. Please publish a blog first."
      return nil
    end
    puts "Your published blogs:"
    @blog_obj.print_blog(current_user_blog)
    puts "Enter the number of the blog you want to create a post in:"
    selected_blog = @blog_obj.find_blog(current_user_blog)
    if selected_blog.nil?
      return nil
    end
    return selected_blog
  end 

  def for_comments(selected_post, user_id)
    puts "Enter your comment:"
    comment = gets.chomp.strip
    if comment.empty?
      puts "Please enter valid comments."
    else
      post_title = selected_post[:post_title]
      post_user = selected_post[:user_id]
      post_content = selected_post[:post_content]
      comments = { user_id: user_id, post_user: post_user, post_title: post_title, post_content: post_content, comment: comment }
      @comments << comments
      puts "Comment added successfully!"
    end
  end

  def my_posts(user_id)
    current_user_blog = @blog_obj.create_blog_validation(user_id, @published_blogs)
    if current_user_blog.empty?
      puts "You don't have any published blogs."
      return nil
    end
    puts "=== Blogs ==="
    @blog_obj.print_blog(current_user_blog)
    puts "Enter the number of the blog you want to view posts:"
    selected_blog = @blog_obj.find_blog(current_user_blog)
    if selected_blog.nil?
      return nil
    end
    posts_selected = @posts.select { |post| post[:blog_title] == selected_blog[:title] }
    return posts_selected
  end

  def post_view(posts)
    posts.each do |post|
      puts " POSTS :- "
      puts "-------------------------------------"
      puts "Blog Title: #{post[:blog_title]}"
      puts "Post Title: #{post[:post_title]}"
      puts "Post Content: #{post[:post_content]}"
      comments = @comments.select { |comment| comment[:post_title] == post[:post_title] }
      if !comments.empty?
        puts "--------------------------------------"
        puts "  COMMENTS :- "
        comments.each do |comment|
          puts "  #{comment[:user_id]} : #{comment[:comment]} "
        end
      end
      puts "========================================"
    end
  end

  def searching_code(search_character, user_id)
    found_posts = []
    followed_blogs = @blog_obj.blog_followers.select { |blog| blog[:user_id] == user_id }
    followed_blogs.each do |blog|
      blog_posts = @posts.select { |post| post[:blog_title] == blog[:blog_title] }
      blog_posts.each do |post|
        if post[:post_title].downcase.include?(search_character)
          found_posts << { blog_title: blog[:blog_title], username: blog[:user_id], post_title: post[:post_title], post_content: post[:post_content] }
        end
      end
    end
    return found_posts
  end
end
