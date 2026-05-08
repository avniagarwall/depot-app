class RatingRangeValidator < ActiveModel::Validator
  def validate(record)
    if record.rating.present? && record.rating > 5
      record.errors.add :rating, "cannot be greater than 5"
    end

    if record.rating.present? && record.rating < 1
      record.errors.add :rating, "cannot be less than 1"
    end
  end
end