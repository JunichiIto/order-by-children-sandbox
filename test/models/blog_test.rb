require "test_helper"

class BlogTest < ActiveSupport::TestCase
  test ".order_by_comment_count" do
    blog_with_two_comments = Blog.create!(title: "こんにちは")
    blog_with_two_comments.comments.create!(content: "やあ")
    blog_with_two_comments.comments.create!(content: "やあやあ")

    blog_with_one_comment = Blog.create!(title: "Hello")
    blog_with_one_comment.comments.create!(content: "Hi")

    blog_without_comments = Blog.create!(title: "Chao!")

    blog_with_three_comments = Blog.create!(title: "にーはお")
    blog_with_three_comments.comments.create!(content: "はお")
    blog_with_three_comments.comments.create!(content: "はおはお")
    blog_with_three_comments.comments.create!(content: "はおはおはお")

    blogs = Blog.order_by_comment_count
    assert_equal [blog_with_three_comments, blog_with_two_comments, blog_with_one_comment, blog_without_comments], blogs

    # コメントの件数も同時に取得する
    blogs = Blog.order_by_comment_count.select("blogs.*, COALESCE(comment_counts.cnt, 0) AS comment_count")
    assert_equal [3, 2, 1, 0], blogs.map(&:comment_count)

    # 他のscopeと組み合わせる
    blog_with_three_comments.update!(created_at: 1.day.ago)
    blogs = Blog.order_by_comment_count.created_today
    assert_equal [blog_with_two_comments, blog_with_one_comment, blog_without_comments], blogs

    # コメントをeager loadする
    blogs = Blog.eager_load(:comments).order_by_comment_count
    assert_equal [blog_with_three_comments, blog_with_two_comments, blog_with_one_comment, blog_without_comments], blogs
  end
end
