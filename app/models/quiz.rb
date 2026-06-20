class Quiz < ApplicationRecord
  has_many :cities, dependent: :destroy

  validates :title, :slug, :region, :duration_seconds, presence: true
  validates :slug,
    uniqueness: true,
    format: { with: /\A[a-z0-9\-]+\z/ }

  validates :duration_seconds, numericality: { greater_than: 0 }
  validates :map_latitude,
    presence: true,
    numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }

  validates :map_longitude,
    presence: true,
    numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }

  validates :map_zoom, numericality: { greater_than: 0 }

  def city_count
    cities.size
  end

  def duration_minutes
    (duration_seconds / 60).ceil
  end

  def city_names
    cities.pluck(:name)
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

  def city_guess_lookup
    cities.each_with_object({}) do |city, hash|
      normalized = city.normalized_name
      hash[normalized] = normalized

      city.aliases.each do |city_alias|
        hash[CityNameNormalizer.call(city_alias)] = normalized
      end
    end
  end

  def all_normalized_city_names
    city_guess_lookup.keys
  end

  def to_param
    slug
  end

  def map_center
    [ map_latitude || 39.0, map_longitude || 35.0 ]
  end

  def map_zoom
    self[:map_zoom] || 6
  end
end
