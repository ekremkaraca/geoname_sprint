class Quiz < ApplicationRecord
  has_many :cities, dependent: :destroy

  validates :title, :slug, :region, :duration_seconds, presence: true
  validates :slug, uniqueness: true
  validates :duration_seconds, numericality: { greater_than: 0 }

  def city_count
    cities.size
  end

  def duration_minutes
    duration_seconds / 60
  end
end
