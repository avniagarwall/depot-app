class ReviewLogger
  def self.after_commit(review)
    Rails.logger.info "📋 ReviewLogger: Review by #{review.reviewer_name} was saved to DB"
  end

  def self.after_destroy(review)
    Rails.logger.info "📋 ReviewLogger: Review by #{review.reviewer_name} was destroyed"
  end
end