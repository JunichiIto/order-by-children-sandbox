class Blog < ApplicationRecord
  has_many :comments

  # この方法だと、以下のような問題点がある
  # - 他のscopeと連結できない
  # - 関連するcommentsをインスタンス化するので、件数が多いとパフォーマンスやメモリ効率が悪い
  # scope :order_by_comment_count, -> do
  #   includes(:comments).sort_by { |blog| blog.comments.size }.reverse
  # end

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

  scope :created_today, -> { where(created_at: Date.current.all_day) }
end
