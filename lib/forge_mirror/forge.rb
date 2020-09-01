require 'puppet_forge'
module ForgeMirror
  class Forge
    @modules = Hash.new

    def self.lookup_modules(modules)
      PuppetForge.user_agent = "ForgeMirror/#{ForgeMirror::VERSION}"
      PuppetForge::Connection.proxy = ForgeMirror.configuration.general[:proxy] unless ForgeMirror.configuration.general[:proxy].nil?

      modules.each do |mod|
        ForgeMirror.log.info("Searching the forge for #{mod}")

        # Search for the module, log error if any
        begin
          m = PuppetForge::Module.find(mod)
        rescue Faraday::ResourceNotFound
          ForgeMirror.log.warn("Unable to find #{mod}")
          next
        end

        c = m.current_release

        # Store relevant information
        @modules[mod] = {
          url: m.homepage_url,
          latest: c.version,
          deps: []
        }

        c.metadata[:dependencies].each do |dep|
          ForgeMirror.log.info("depends on #{dep[:name]} #{dep[:version_requirement]}")

          @modules[mod][:deps] << dep[:name]
        end
      end

      @modules
    end

    def self.modules
      @modules
    end
  end
end
