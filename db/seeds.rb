turkey = Quiz.find_or_create_by!(slug: "turkey-cities") do |quiz|
  quiz.title = "Turkey Cities"
  quiz.region = "Turkey"
  quiz.duration_seconds = 300
  quiz.map_latitude = 39.0
  quiz.map_longitude = 35.0
  quiz.map_zoom = 6
end

cities = [
  { name: "İstanbul", latitude: 41.0082, longitude: 28.9784, population: 15_000_000, aliases: [ "Istanbul" ] },
  { name: "Ankara", latitude: 39.9334, longitude: 32.8597, population: 5_800_000, aliases: [] },
  { name: "İzmir", latitude: 38.4237, longitude: 27.1428, population: 4_400_000, aliases: [ "Izmir" ] },
  { name: "Bursa", latitude: 40.1828, longitude: 29.0663, population: 3_200_000, aliases: [] },
  { name: "Antalya", latitude: 36.8969, longitude: 30.7133, population: 2_700_000, aliases: [] },
  { name: "Konya", latitude: 37.8746, longitude: 32.4932, population: 2_300_000, aliases: [] },
  { name: "Adana", latitude: 37.0000, longitude: 35.3213, population: 2_300_000, aliases: [] },
  { name: "Gaziantep", latitude: 37.0662, longitude: 37.3833, population: 2_100_000, aliases: [ "Antep" ] },
  { name: "Şanlıurfa", latitude: 37.1591, longitude: 38.7969, population: 2_200_000, aliases: [ "Urfa", "Sanliurfa" ] },
  { name: "Diyarbakır", latitude: 37.9144, longitude: 40.2306, population: 1_800_000, aliases: [ "Diyarbakir" ] },
  { name: "Muğla", latitude: 37.2167, longitude: 28.3667, population: 1_099_000, aliases: [ "Mugla" ] },
  { name: "Ula", latitude: 37.1036, longitude: 28.4147, population: 27_300, aliases: [] },
  { name: "Karabörtlen", latitude: 37.0405, longitude: 28.5054, population: 1_600, aliases: [ "Karabortlen" ] }
]

cities.each do |attrs|
  normalized_name = CityNameNormalizer.call(attrs[:name])

  City.find_or_create_by!(
    quiz: turkey,
    normalized_name: normalized_name
  ) do |city|
    city.name = attrs[:name]
    city.latitude = attrs[:latitude]
    city.longitude = attrs[:longitude]
    city.population = attrs[:population]
    city.aliases = attrs[:aliases]
  end
end
