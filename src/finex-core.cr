require "uri"
require "redis"

module Finex
  @@cache : Redis?

  NAME    = "Finex"
  VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify.downcase }}

  Log         = ::Log.for(NAME)
  LOG_BACKEND = ActionController.default_backend

  ENVIRONMENT = ENV["FINEX_ENV"]? || "development"

  PORT          = (ENV["PORT"]? || 3000).to_i
  WS_PORT          = (ENV["WS_PORT"]? || 8081).to_i
  URL_HOST          = ENV["URL_HOST"]? || "0.0.0.0"
  PROCESS_COUNT = (ENV["THREADS"]? || 1).to_i

  class Error < Exception
    @@default_code = 2000

    property code : Int32
    property text : String

    def initialize(@code, @text = "")
      if @text != ""
        super("#{@code}: #{text}")
      else
        super("#{@code}")
      end
    end
  end

  def self.running_in_production?
    ENVIRONMENT == "production"
  end

  def self.logger
    Log
  end

  def self.log_level
    ::Log::Severity::Debug
  end

  def self.cache
    uri = URI.parse(ENV["REDIS_URL"])
    @@cache ||= Redis.new(host: uri.host.not_nil!, port: uri.port.not_nil!, password: uri.password)
  end
end

::Log.setup "*", level: Finex.log_level

require "./auth/**"
require "./mq/**"
require "./stream/**"
