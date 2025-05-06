module RetroBridge
  class Web < Sinatra::Base
    get "/bin/weather.php" do
      template = <<~PLIST
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Temperature</key>
            <integer>%{temp}</integer>
            <key>Units</key>
            <string>%{units}</string>
            <key>Condition</key>
            <string>%{condition}</string>
            <key>Image</key>
            <string>%{icon}</string>
            <key>NextRefresh</key>
            <integer>1800</integer>
        </dict>
        </plist>
      PLIST

      code = params["ZipCode"]

      # Stattoo 1.2 sends 1.1. No other versions known yet.
      _ver = params["Version"] || "1.1"

      # Despite the param name ZipCode, we can accept anything as a search term.
      # Work well: ICAO airport codes, city names, US zip codes
      places = Geocoding.new.search(code)

      # The first match is usually good, and there's no way for the client to pick anyway
      place = places.first

      weather = Weather.new.at_coordinates(place.latitude, place.longitude)

      headers("Content-Type" => "application/xml")

      puts place
      puts weather

      format(template, {
        temp: Weather.c2f(weather.temperature).floor,
        units: "F",
        condition: "None",
        icon: "weather-" + icon_for(weather) + ".png"
      })
    end

    private

    def icon_for(weather)
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
      elsif weather.cloud_cover > 0.75
        # The icon for "fair" (at least in Stattoo 1.2) is actually just a cloud
        # and the icon for "mostlycloudy" is the same as "partiallycloudy"
        "fair"
      elsif weather.cloud_cover > 0.20
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
