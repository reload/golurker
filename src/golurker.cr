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
  rescue ex
    error = ex.to_s

    ECR.render("view/error.ecr");
  end

  get "/check/:index/:stamp" do |env|
    host = Go::SITES[env.params.url["index"].to_i]
    timestamp = env.params.url["stamp"].to_i

    site_timestamp = Go.get_frontpage_timestamp(host)
    if site_timestamp >= timestamp
      "<span style='color: darkgreen'>OK</span>"
    else
      difference = Time::Span.new(seconds: timestamp - site_timestamp)
      if timestamp > (Time.utc - 1.hour).to_unix
        "<span style='color: darkyellow'>Pending, #{format_time_span(difference)} older</span>"
      else
        "<span style='color: darkred'>Error, #{format_time_span(difference)} older</span>"
      end
    end
  rescue ex
    "<span style='color: darkred'>Internal error: #{ex}</span>"
  end

  def self.format_time_span(span : Time::Span) : String
    case
    when span.total_weeks > 1
      "#{span.total_weeks.round(2)} week(s)"
    when span.total_days > 1
      "#{span.total_days.round(2)} day(s)"
    when span.total_hours > 1
      "#{span.total_hours.round(2)} hour(s)"
    else
      "#{span.total_seconds} second(s)"
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
