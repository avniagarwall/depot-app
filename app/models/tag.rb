class Tag < ApplicationRecord
  has_many :product_tags, dependent: :destroy
  has_many :products, through: :product_tags

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }, if: :name?

  before_save :normalize_name, if: :name_changed?

  scope :ordered, -> { order(:name) }

  private

    def normalize_name
      self.name = name.strip.titleize
    end
end
