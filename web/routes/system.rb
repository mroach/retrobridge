module RetroBridge
  class Web < Sinatra::Base
    get "/healthz" do
      "OK #{Time.now.utc}"
    end

    get "/statusz" do
      {
        "Ruby" => [RUBY_ENGINE, RUBY_VERSION, RUBY_PLATFORM].join(" ")
      }.map { |k, v| format("%s: %s", k, v) }.join("\n")
    end
  end
end
