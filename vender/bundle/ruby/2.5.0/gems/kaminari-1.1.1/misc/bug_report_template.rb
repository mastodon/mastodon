begin
  require "bundler/inline"
rescue LoadError => e
  $stderr.puts "Bundler version 1.10 or later is required. Please update your Bundler"
  raise e
end

gemfile(true) do
  source "https://rubygems.org"
  # Activate the gem you are reporting the issue against.
  gem "railties", "5.0.1"
  gem "activerecord", "5.0.1"
  gem "sqlite3"
  gem "kaminari-core", "1.0.1"
  gem "kaminari-activerecord", "1.0.1"
end

require "active_record"
require "minitest/autorun"
require "logger"

require "kaminari/core"
require "kaminari/activerecord"

# Ensure backward compatibility with Minitest 4
Minitest::Test = MiniTest::Unit::TestCase unless defined?(Minitest::Test)

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
  end

  create_table :comments, force: true do |t|
    t.integer :post_id
  end
end

class Post < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post
end

class BugTest < Minitest::Test
  def test_pagination_stuff
    post = Post.create!
    post.comments << Comment.create!

    assert_equal 1, Post.page(1).total_count
    assert_equal 1, post.reload.comments.page(1).total_count
  end
end
