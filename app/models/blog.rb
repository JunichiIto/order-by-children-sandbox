class Blog < ApplicationRecord
  has_many :comments

  scope :order_by_comment_count, -> do
    sql = <<~SQL
      LEFT OUTER JOIN (
        SELECT c.blog_id, COUNT(*) AS cnt
        FROM comments c 
        GROUP BY c.blog_id
      ) comment_counts ON comment_counts.blog_id = blogs.id
    SQL
    joins(sql).order("comment_counts.cnt DESC")
  end
end
