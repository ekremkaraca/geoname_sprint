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
      hash[
        CityNameNormalizer.call(city.normalized_name)
      ] = city.name
    end
  end

  def city_coordinates
    cities.each_with_object({}) do |city, hash|
      hash[
        CityNameNormalizer.call(city.normalized_name)
      ] = {
        name: city.name,
        latitude: city.latitude,
        longitude: city.longitude
      }
    end
  end

  def city_guess_lookup
    cities.each_with_object({}) do |city, hash|
      normalized = CityNameNormalizer.call(city.normalized_name)
      hash[normalized] = normalized

      city.aliases.each do |city_alias|
        hash[CityNameNormalizer.call(city_alias)] = normalized
      end
    end
  end

  def all_normalized_city_names
    city_guess_lookup.keys
  end
end
