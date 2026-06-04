class Tag < ApplicationRecord
  has_many :product_tags, dependent: :destroy
  has_many :products, through: :product_tags

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  before_save :normalize_name

  scope :ordered, -> { order(:name) }

  private

    def normalize_name
      self.name = name.strip.titleize
    end
end
