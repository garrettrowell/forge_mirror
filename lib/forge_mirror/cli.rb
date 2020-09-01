require 'thor'

module ForgeMirror
  class CLI < Thor
    desc 'update', 'Update internal mirrors of Forge modules'
    option :puppetfile_path, aliases: '-p', default: ForgeMirror::Configuration.defaults[:puppetfile_path]
    option :work_dir, aliases: '-w', default: ForgeMirror::Configuration.defaults[:work_dir]
    option :access_token, default: ForgeMirror::Configuration.defaults[:github][:access_token]
    option :organization, default: ForgeMirror::Configuration.defaults[:github][:organization]
    option :private_key, default: ForgeMirror::Configuration.defaults[:git][:private_key]
    option :public_key, default: ForgeMirror::Configuration.defaults[:git][:public_key]
    option :proxy, default: ForgeMirror::Configuration.defaults[:proxy]
    option :internal_api_endpoint, default: ForgeMirror::Configuration.defaults[:github][:internal_api_endpoint]
    option :config_file, default: ForgeMirror::Configuration.defaults[:config_file]
    def update
      # Config precedence (lowest to highest):
      #   1. default values
      #   2. configuration file values
      #   3. cli parameters

      ForgeMirror.configure(options) do |config|
      end

      ForgeMirror.log.info(ForgeMirror.configuration.inspect)
      puppetfile_modules = ForgeMirror::Puppetfile.parse(ForgeMirror.configuration.general[:puppetfile_path])
      forge_modules = ForgeMirror::Forge.lookup_modules(puppetfile_modules)
      ForgeMirror::Github.check_repos(forge_modules)
    end

    default_task :update
  end
end
