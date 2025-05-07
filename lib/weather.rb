module RetroBridge
  class Weather
    Error = Class.new(StandardError)
    Report = Data.define(:time, :coordinates, :temperature, :cloud_cover, :rain, :showers, :snowfall, :wind_gusts, :is_day) do
      def day? = is_day

      def night? = !day?
    end

    class << self
      F_FACTOR = 9 / 5.0
      F_FREEZING = 32

      def c2f(c) = F_FREEZING + c * F_FACTOR

      def f2c(f) = (f - 32) / F_FACTOR
    end

    def at_coordinates(latitude, longitude)
      conn = Faraday.new("https://api.open-meteo.com/v1") do |f|
        f.response(:json)
      end

      resp = conn.get("forecast", {
        latitude:,
        longitude:,
        current: "temperature_2m,precipitation,cloud_cover,rain,showers,snowfall,wind_gusts_10m,is_day"
      })

      unless resp.success?
        raise Error, "Couldn't load weather for #{latitude},#{longitude}"
      end

      data = resp.body.fetch("current")

      Report.new(
        coordinates: [latitude, longitude],
        time: Time.parse(data.fetch("time")),
        temperature: data.fetch("temperature_2m"),
        cloud_cover: data.fetch("cloud_cover"),
        rain: data.fetch("rain"),
        showers: data.fetch("showers"),
        snowfall: data.fetch("snowfall"),
        wind_gusts: data.fetch("wind_gusts_10m"),
        is_day: data.fetch("is_day") == 1
      )
    end
  end
end
