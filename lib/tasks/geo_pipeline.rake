require "faraday"
require "json"

namespace :geo do
  desc "Generate pending city data using cloud OpenRouter API"
  task :generate_cities, [ :country, :count ] => :environment do |t, args|
    country = args[:country] || "Turkey"
    count = (args[:count] || 15).to_i

    staging_dir = Rails.root.join("db", "raw_seeds")
    FileUtils.mkdir_p(staging_dir)
    file_path = staging_dir.join("pending_#{country.downcase}.json")

    # Load the GBNF grammar file
    grammar_path = Rails.root.join("lib", "geoname.gbnf")
    unless File.exist?(grammar_path)
      puts "❌ Error: Missing 'geoname.gbnf' file at root. Please create it first."
      exit 1
    end
    grammar_content = File.read(grammar_path)

    # Fetch the key from our local environment configurations
    api_key = ENV["OPENROUTER_API_KEY"]
    if api_key.blank?
      puts "❌ Error: Missing OPENROUTER_API_KEY environment variable."
      exit 1
    end

    puts "☁️ Connecting to OpenRouter cloud pipeline..."
    puts "🌍 Target: Requesting #{count} factual cities for #{country}"

    # Configure Faraday to point to the unified cloud gateway
    client = Faraday.new(url: "https://openrouter.ai") do |f|
      f.request :json
      f.response :json
      f.headers["Authorization"] = "Bearer #{api_key}"
      f.headers["HTTP-Referer"] = "http://localhost:3000" # Required by OpenRouter spec
      f.headers["X-Title"] = "GeoName Sprint"
      f.options.timeout = 60 # Cloud models stream fast, 1 minute is plenty
    end

    # Build the payload using strict schema parameters rather than GBNF grammars
    payload = {
      model: ENV["OPENROUTER_MODEL"],
      messages: [
          {
            role: "system",
            content: <<~TEXT
              You are a strict, factual geographic database generator.
              Your task is to return real, verified cities for the requested country.

              CRITICAL RULES:
              1. Every city MUST have its true, distinct latitude and longitude (no repeating sequences).
              2. Do NOT invent fake cities or city aliases.
              3. Do NOT repeat the same phrase or nickname across different cities.
              4. Stop generating immediately when you reach the requested count.

              EXAMPLE FOR TURKEY:
              [
                {"name": "Ankara", "aliases": [], "map_latitude": 39.928889, "map_longitude":  32.854722},
                {"name": "Istanbul", "aliases": ["İstanbul"], "map_latitude": 41.013611, "map_longitude":  28.955},
                {"name": "Gaziantep", "aliases": ["Antep"], "map_latitude": 37.065833, "map_longitude": 37.378056},
                {"name": "Şanlıurfa", "aliases": ["Urfa"], "map_latitude": 37.158333, "map_longitude": 38.791667},
              ]
            TEXT
          },
          {
            role: "user",
            content: "Generate an array containing exactly #{count} distinct, major real-world cities in #{country} following the required schema structure."
          }
      ],
      temperature: 0.0, # Kill the creativity entirely to stop the loops

      chat_template_kwargs: {
        enable_thinking: false
      },

      response_format: {
        type: "json_object",
        schema: grammar_content
      }
    }

    begin
      response = client.post("/api/v1/chat/completions", payload)

      if response.success?
        raw_json_string = response.body.dig("choices", 0, "message", "content")

        # Clean up common markdown fences that cloud endpoints can sometimes append
        raw_json_string = raw_json_string.gsub(/```json\s*/i, "").gsub(/```\s*/, "").strip

        # Double check parsing passes before committing to our staging directory
        JSON.parse(raw_json_string)

        File.write(file_path, raw_json_string)
        puts "============================================="
        puts "✅ Cloud Verification Complete!"
        puts "💾 Saved raw data to: #{file_path}"
        puts "👉 Run your server and navigate to your Reading Canvas to inspect."
        puts "============================================="
      else
        puts "❌ Cloud provider rejected request: #{response.status}"
        puts "Details: #{response.body}"
      end

    rescue JSON::ParserError
      puts "❌ Failed to parse response string as valid JSON structure."
      puts "Raw Content received: #{raw_json_string}"
    rescue => e
      puts "❌ Connection or execution failure: #{e.message}"
    end
  end
end
