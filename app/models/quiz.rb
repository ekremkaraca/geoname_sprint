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

  def normalized_city_names
    cities.pluck(:normalized_name)
  end

  def city_lookup
    cities.each_with_object({}) do |city, hash|
      hash[city.normalized_name] = city.name
    end
  end

  def city_coordinates
    cities.each_with_object({}) do |city, hash|
      hash[city.normalized_name] = {
        name: city.name,
        latitude: city.latitude,
        longitude: city.longitude
      }
    end
  end
end
