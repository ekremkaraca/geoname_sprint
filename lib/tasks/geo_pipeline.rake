require "faraday"
require "json"

namespace :geo do
  desc "Generate city data via OpenRouter and save to staging"
  task :generate_cities, [ :country, :count ] => :environment do |_t, args|
    country = args[:country] || "Turkey"
    count = (args[:count] || 15).to_i

    api_key = ENV["OPENROUTER_API_KEY"]
    model  = ENV["OPENROUTER_MODEL"]

    if api_key.blank?
      puts "❌ Missing OPENROUTER_API_KEY environment variable."
      exit 1
    end

    if model.blank?
      puts "❌ Missing OPENROUTER_MODEL environment variable."
      exit 1
    end

    staging_dir = Rails.root.join("db", "raw_seeds")
    FileUtils.mkdir_p(staging_dir)
    file_path = staging_dir.join("pending_#{country.downcase}.json")

    puts "☁️  Generating #{count} cities for #{country} via OpenRouter..."
    puts "   Model: #{model}"

    client = Faraday.new(url: "https://openrouter.ai") do |f|
      f.request :json
      f.response :json
      f.headers["Authorization"] = "Bearer #{api_key}"
      f.headers["HTTP-Referer"] = "http://localhost:3000"
      f.headers["X-Title"] = "GeoName Sprint"
      f.options.timeout = 60
    end

    payload = {
      model: model,
      messages: [
        {
          role: "system",
          content: <<~TEXT
            You are a strict, factual geographic database generator.
            Return real, verified cities for the requested country.

            CRITICAL RULES:
            1. Every city MUST have its true, distinct latitude and longitude.
            2. Do NOT invent fake cities or city aliases.
            3. Do NOT repeat the same alias across different cities.
            4. Stop when you reach the requested count.

            Respond with a JSON object containing a "cities" array:

            {"cities": [
              {"name": "Ankara", "aliases": [], "latitude": 39.928889, "longitude": 32.854722},
              {"name": "Istanbul", "aliases": ["İstanbul"], "latitude": 41.013611, "longitude": 28.955},
              {"name": "Gaziantep", "aliases": ["Antep"], "latitude": 37.065833, "longitude": 37.378056}
            ]}
          TEXT
        },
        {
          role: "user",
          content: "Generate an array of exactly #{count} distinct, major real-world cities in #{country} following the schema above."
        }
      ],
      temperature: 0.0,
      response_format: { type: "json_object" }
    }

    begin
      response = client.post("/api/v1/chat/completions", payload)

      if response.success?
        raw_json_string = response.body.dig("choices", 0, "message", "content")
          &.gsub(/```json\s*/i, "")
          &.gsub(/```\s*/, "")
          &.strip

        parsed = JSON.parse(raw_json_string)
        cities = parsed["cities"]

        unless cities.is_a?(Array) && cities.any?
          puts "❌ Response missing a 'cities' array."
          exit 1
        end

        File.write(file_path, JSON.pretty_generate(parsed))

        puts "============================================="
        puts "✅ Generated #{cities.size} cities for #{country}"
        puts "💾 Saved to: #{file_path}"
        puts "👉 Run bin/rails 'geo:import_cities[#{country}]' to seed the database."
        puts "============================================="
      else
        puts "❌ Request failed: #{response.status}"
        puts response.body
        exit 1
      end

    rescue JSON::ParserError => e
      puts "❌ Failed to parse response as JSON: #{e.message}"
      puts "Raw content: #{raw_json_string}"
      exit 1
    rescue => e
      puts "❌ Error: #{e.message}"
      exit 1
    end
  end

  desc "Import staged city data into the database"
  task :import_cities, [ :country ] => :environment do |_t, args|
    country = args[:country] || "Turkey"
    file_path = Rails.root.join("db", "raw_seeds", "pending_#{country.downcase}.json")

    unless File.exist?(file_path)
      puts "❌ No staging file at #{file_path}. Run geo:generate_cities first."
      exit 1
    end

    data = JSON.parse(File.read(file_path))
    cities = data["cities"]

    unless cities.is_a?(Array) && cities.any?
      puts "❌ Staging file does not contain a valid 'cities' array."
      exit 1
    end

    puts "📦 Importing #{cities.size} cities for #{country}..."

    quiz = Quiz.find_or_create_by!(slug: "#{country.downcase}-cities") do |q|
      q.title = "#{country} Cities"
      q.region = country
      q.duration_seconds = 300
      q.map_latitude = 39.0
      q.map_longitude = 35.0
      q.map_zoom = 6
    end

    imported = 0
    skipped = 0

    cities.each do |attrs|
      normalized_name = CityNameNormalizer.call(attrs["name"])

      if City.exists?(quiz: quiz, normalized_name: normalized_name)
        puts "   ⏭  #{attrs["name"]} already exists, skipping"
        skipped += 1
        next
      end

      City.create!(
        quiz: quiz,
        name: attrs["name"],
        normalized_name: normalized_name,
        latitude: attrs["latitude"],
        longitude: attrs["longitude"],
        aliases: Array(attrs["aliases"])
      )

      imported += 1
      puts "   ✓ #{attrs["name"]}"
    end

    puts "============================================="
    puts "✅ Import complete for #{country}"
    puts "   Created: #{imported} cities"
    puts "   Skipped: #{skipped} (already exist)"
    puts "   Quiz:    #{quiz.title} (#{quiz.cities.count} total cities)"
    puts "============================================="
  end
end
