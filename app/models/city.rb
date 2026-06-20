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
  validates :population,
    numericality: {
      greater_than_or_equal_to: 0
    },
    allow_nil: true

  validate :aliases_are_unique_within_quiz

  before_validation :normalize_aliases

  private

  def normalize_aliases
    return unless aliases.is_a?(Array)

    self.aliases = aliases
      .map { |value| CityNameNormalizer.call(value) }
      .reject(&:blank?)
  end

  def aliases_are_unique_within_quiz
    return if quiz.blank?

    unless aliases.is_a?(Array)
      errors.add(:aliases, "must be an array")
      return
    end

    normalized_aliases = Array(aliases).map { |value|
      CityNameNormalizer.call(value) }.reject(&:blank?)

    if normalized_aliases.uniq.size != normalized_aliases.size
      errors.add(:aliases, "must be unique")
    end

    quiz.cities.where.not(id: id).each do |city|
      other_keys = [
        city.normalized_name,
        *Array(city.aliases).map { |a| CityNameNormalizer.call(a) }
      ]

      if (normalized_aliases & other_keys).any?
        errors.add(:aliases, "must not conflict with another city")
        break
      end
    end
  end
end
