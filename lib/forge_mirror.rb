require 'forge_mirror/version'
require 'forge_mirror/configuration'
require 'forge_mirror/cli'
require 'forge_mirror/forge'
require 'forge_mirror/util'
require 'forge_mirror/logger'
require 'forge_mirror/puppetfile'
require 'forge_mirror/github'
require 'forge_mirror/git'

module ForgeMirror
  class Error < StandardError; end

  class << self
    attr_accessor :configuration

    def configure(opts)
      self.configuration ||= Configuration.new(opts)
      yield(configuration)
    end

#    def reset
#      self.configuration = Configuration.new
#    end
  end
end
