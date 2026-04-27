require "kemal"
require "ecr"
require "dotenv"
require "./go"

# Simple service for monitoring Go frontpage.
module Golurker
  VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify }}

  # Demo "sites".
  DEMO_SITES = %w(success failure error)
  # Main page.
  get "/" do
    sites = Go::SITES
    timestamp = Go.get_frontpage_timestamp("delingstjenesten.dk")

    ECR.render("view/index.ecr");
  end

  get "/check/:index/:stamp" do |env|
    host = Go::SITES[env.params.url["index"].to_i]
    timestamp = env.params.url["stamp"].to_i

    site_timestamp = Go.get_frontpage_timestamp(host)
    if site_timestamp >= timestamp
      "<span style='color: darkgreen'>OK</span>"
    else
      if timestamp > (Time.utc - 1.hour).to_unix
        "<span style='color: darkyellow'>Pending #{site_timestamp} #{timestamp}</span>"
      else
        "<span style='color: darkred'>Error #{site_timestamp} #{timestamp}</span>"
      end
    end
  end

  # For testing/development.
  # get "/demo" do
  #   sites = DEMO_SITES

  #   ECR.render("view/index.ecr");
  # end

  # get "/demo/:index" do |env|
  #   state = DEMO_SITES[env.params.url["index"].to_i]

  #   state
  # end

  Dotenv.load

  Kemal.run
end
