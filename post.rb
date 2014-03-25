require "./comment.rb"
# require "./picture.rb"

class Post
  include DataMapper::Resource
  
  property :id, Serial
  property :title, String
  property :body, Text
  property :created_at, DateTime

  has n, :comments #, :through => Resource
  # has n, :pictures

end

DataMapper.finalize

# DataMapper.auto_migrate!

Post.auto_upgrade!
Comment.auto_upgrade!
# Picture.auto_upgrade!
