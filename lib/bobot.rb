require 'bobot/engine'
require 'bobot/exceptions'
require 'bobot/error_parser'
require 'bobot/graph_facebook'
require 'bobot/configuration'
require 'bobot/profile'
require 'bobot/user'
require 'bobot/buttons'
require 'bobot/commander'
require 'bobot/event'
require 'bobot/page'

module Bobot
  def self.configure
    yield config
  end

  def self.config
    @config ||= Configuration.new
  end

  def self.config=(config)
    @config = config
  end

  configure do |config|
    config.pages = []
  end
end
