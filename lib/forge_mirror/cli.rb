require 'thor'

module ForgeMirror
  class CLI < Thor
    desc 'update', 'Update internal mirrors of Forge modules'
    option :puppetfile_path, aliases: '-p', default: ForgeMirror::Configuration.defaults[:general][:puppetfile_path]
    option :work_dir, aliases: '-w', default: ForgeMirror::Configuration.defaults[:general][:work_dir]
    option :access_token, default: ForgeMirror::Configuration.defaults[:github][:access_token]
    option :organization, default: ForgeMirror::Configuration.defaults[:github][:organization]
    option :private_key, default: ForgeMirror::Configuration.defaults[:git][:private_key]
    option :public_key, default: ForgeMirror::Configuration.defaults[:git][:public_key]
    option :proxy, default: ForgeMirror::Configuration.defaults[:general][:proxy]
    option :internal_api_endpoint, default: ForgeMirror::Configuration.defaults[:github][:internal_api_endpoint]
    option :config_file, default: ForgeMirror::Configuration.defaults[:general][:config_file]
    def update
      # Config precedence (lowest to highest):
      #   1. default values
      #   2. configuration file values
      #   3. cli parameters

      # this block configures using defaults and cli options
      ForgeMirror.configure do |config|
        config.general = {
          puppetfile_path: options[:puppetfile_path],
          work_dir: options[:work_dir],
          proxy: options[:proxy],
          config_file: options[:config_file]
        }
        config.github = {
          access_token: options[:access_token],
          organization: options[:organization],
          internal_api_endpoint: options[:internal_api_endpoint]
        }
        config.git = {
          public_key: options[:public_key],
          private_key: options[:private_key]
        }
      end

      # If config file is found merge into runtime config as long as
      # user hasn't already set via cli
      ForgeMirror::Configuration.merge_file(ForgeMirror.configuration.general[:config_file])

      puppetfile_modules = ForgeMirror::Puppetfile.parse(ForgeMirror.configuration.general[:puppetfile_path])
      forge_modules = ForgeMirror::Forge.lookup_modules(puppetfile_modules)
      ForgeMirror::Github.check_repos(forge_modules)
    end

    default_task :update
  end
end
