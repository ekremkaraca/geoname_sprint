class City < ApplicationRecord
  belongs_to :quiz

  validates :name, :normalized_name, :latitude, :longitude, presence: true
  validates :normalized_name, uniqueness: { scope: :quiz_id }
  validates :latitude,
    numericality: {
      greater_than_or_equal_to: -90,
      less_than_or_equal_to: 90
    }
  validates :longitude,
    numericality: {
      greater_than_or_equal_to: -180,
      less_than_or_equal_to: 180
    }
end
