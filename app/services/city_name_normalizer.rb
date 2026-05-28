class CityNameNormalizer
  TURKISH_MAP = {
    "ç" => "c",
    "ğ" => "g",
    "ş" => "s",
    "ı" => "i",
    "ö" => "o",
    "ü" => "u"
  }.freeze

  def self.call(value)
    value
      .to_s
      .strip
      .downcase
      .then { |text| TURKISH_MAP.reduce(text) { |acc, (from, to)| acc.gsub(from, to) } }
      .gsub(/[^a-z0-9\s-]/, "")
      .squeeze(" ")
  end
end
