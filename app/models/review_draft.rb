class ReviewDraft
  # ACTIVE MODEL DIRTY
  # Tracks changes to attributes before they are saved
  include ActiveModel::Dirty

  attr_reader :body, :rating

  define_attribute_methods :body, :rating

  def body=(value)
    body_will_change! unless value == @body
    @body = value
  end

  def rating=(value)
    rating_will_change! unless value == @rating
    @rating = value
  end

  def save
    # simulate saving - moves changes to previous_changes
    changes_applied
  end

  def reload!
    # clears all dirty data
    clear_changes_information
  end

  def rollback!
    # restores previous values
    restore_attributes
  end
end