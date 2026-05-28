class City < ApplicationRecord
  belongs_to :quiz

  validates :name, :normalized_name, :latitude, :longitude, presence: true
  validates :normalized_name, uniqueness: { scope: :quiz_id }
end
