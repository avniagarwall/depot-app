class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :products, through: :taggings

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  before_save :normalize_name

  scope :ordered, -> { order(:name) }

  private

    def normalize_name
        self.name = name.strip.titleize
    end
end
