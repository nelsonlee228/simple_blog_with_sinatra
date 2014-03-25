require "sinatra"
# require "pony"
require "data_mapper"
require 'dm-timestamps'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/blog.db" )
# DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/comment.db" )
# DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/blog.db")

require "./post.rb"
require "./comment.rb"

use Rack::MethodOverride
# require "./picture.rb"

enable :sessions

helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401 #, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['Nelson', '1234']
  end
end

get "/" do
  @posts = Post.all
  erb :posts, layout: :default_template
end

get "/post" do
  protected!
  erb :form_post, layout: :default_template
end

post "/post" do
  @post = Post.create( title: params[:title],
                       body: params[:body],
                       )
  redirect '/'
end

get "/admin" do
  protected!
  @posts = Post.all
  @authorized = true
  erb :posts, layout: :default_template
end

get "/post/:id" do |id|
  @post = Post.get(id)
  @comments = @post.comments.all( :order => [:created_at.desc])
  erb :post, layout: :default_template
end

delete "/post/:id" do |id|
  post = Post.get(id)
  comments = post.comments.all
  comments.destroy
  post.destroy

  redirect back
end

put "/post/:id" do |id|
  post = Post.get(id)
  post.title = params[:title]
  post.body = params[:body]
  post.save
  redirect '/'
end

get "/post/:id/update" do |id|
   @post = Post.get(id)
   @render_form = true
   erb :form_post, layout: :default_template
end

get "/comment" do
  erb :form_comment, layout: :default_template
end

post "/post/:id/comment" do |id|
  post = Post.get(id)
  @comment = post.comments.create( comment: params[:comment])
  redirect back
end



