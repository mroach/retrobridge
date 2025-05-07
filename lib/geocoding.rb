module RetroBridge
  class Geocoding
    Place = Data.define(:name, :latitude, :longitude, :country, :timezone, :type)

    Error = Class.new(StandardError)

    def search(term)
      conn = Faraday.new(url: "https://geocoding-api.open-meteo.com/v1") do |f|
        f.response(:json)
      end

      resp = conn.get("search", {name: term, count: 10, format: "json"})

      unless resp.success?
        raise Error, "Request failed: #{resp.status}"
      end

      places = resp.body.fetch("results")

      places.map do |data|
        Place.new(
          name: data.fetch("name"),
          latitude: data.fetch("latitude"),
          longitude: data.fetch("longitude"),
          country: data.fetch("country_code"),
          timezone: data.fetch("timezone"),
          type: data.fetch("feature_code")
        )
      end
    end
  end
end
