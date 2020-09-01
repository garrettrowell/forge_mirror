require 'puppetfile-resolver'

module ForgeMirror
  class Puppetfile
    @modules = Array.new

    def self.parse(puppetfile_path)
      content = File.open(puppetfile_path, 'rb') { |f| f.read }
      puppetfile = PuppetfileResolver::Puppetfile::Parser::R10KEval.parse(content)

      # Validate the Puppetfile
      unless puppetfile.valid?
        ForgeMirror.log.error('Puppetfile is not valid')
        puppetfile.validation_errors.each { |err| ForgeMirror.log.error(err) }
        exit 1
      end

      # Iterate over discovered modules and store normalized slugs
      puppetfile.modules.each do |mod|
        slug = PuppetForge::V3.normalize_name(mod.title)
        ForgeMirror.log.info("found #{slug} in puppetfile")
        @modules << slug
      end

      @modules
    end

    def self.modules
      @modules
    end
  end
end
