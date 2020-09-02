require 'forge_mirror/version'
require 'forge_mirror/configuration'
require 'forge_mirror/cli'
require 'forge_mirror/forge'
require 'forge_mirror/util'
require 'forge_mirror/logger'
require 'forge_mirror/puppetfile'
require 'forge_mirror/github'
require 'forge_mirror/git'
require 'ostruct'

module ForgeMirror
  class Error < StandardError; end

  def self.configuration
    @configuration ||= OpenStruct.new
  end

  def self.configure
    yield(configuration)
  end

end
