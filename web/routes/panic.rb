module RetroBridge
  class Web < Sinatra::Base
    get "/bin/weather.php" do
      template = <<~PLIST
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Temperature</key>
            <integer>%{temperature}</integer>
            <key>Units</key>
            <string>%{units}</string>
            <key>Condition</key>
            <string>%{condition}</string>
            <key>Image</key>
            <string>%{image}</string>
            <key>NextRefresh</key>
            <integer>1800</integer>
        </dict>
        </plist>
      PLIST

      # Stattoo 1.2 sends 1.1. No other versions known yet.
      _ver = params["Version"] || "1.1"

      code = params["ZipCode"]&.strip
      halt 400, "Missing required `ZipCode` query parameter" if code.empty?

      # There's no way anything under 3 chars can produce a good result.
      halt 400, "Query is too short" if code.length < 3

      # Despite the param name ZipCode, we can accept anything as a search term.
      # Work well: ICAO airport codes, city names, US zip codes
      places = Geocoding.new.search(code)

      halt 403, "Couldn't find a place named '#{code}'" if places.none?

      # The first match is usually the best. There are cases where it isn't,
      # like if you're in London, Ontario and search for London.
      # There's no way for a client to pick so go with the first which is usually right.
      place = places.first
      logger.info "Looked-up '#{code}' and got #{place}"

      weather = Weather.new.at_coordinates(place.latitude, place.longitude)
      logger.info "Weather for '#{place.name}': #{weather}"

      headers("content-type" => "application/xml")

      # Only tested on Stattoo 1.2, but it seems to only want the temperature
      # in Fahrenheit and doesn't use the units attribute.
      # Temp must be an integer.
      # The weather icons are files in the Stattoo app bundle
      format(template, {
        temperature: Weather.c2f(weather.temperature).round,
        units: "F",
        condition: "None",
        image: "weather-" + image_for(weather) + ".png"
      })
    end

    private

    def image_for(weather)
      # Available icons in Stattoo 1.2:
      # chancetstorm fair flurries lightning mostlycloudy partiallycloudy rain showers snow snowrain sun wind

      if weather.snowfall.positive? && weather.rain.positive?
        "snowrain"
      elsif weather.snowfall > 5
        "snow"
      elsif weather.snowfall.positive?
        "flurries"
      elsif weather.rain.positive?
        "rain"
      elsif weather.cloud_cover > 75
        # The icon for "fair" (at least in Stattoo 1.2) is actually just a cloud
        # and the icon for "mostlycloudy" is the same as "partiallycloudy"
        "fair"
      elsif weather.cloud_cover > 20
        "partiallycloudy"
      elsif weather.wind_gusts > 20
        "wind"
      elsif weather.day?
        "sun"
      else
        "fair"
      end
    end
  end
end
