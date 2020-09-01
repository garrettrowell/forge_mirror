module ForgeMirror
  class Configuration
    def initialize(opts)
      # cli specified config file if set. otherwise try the default location
      config_file = opts[:config_file] ||= @@default[:config_file]
      # read in any config present in config file
      yaml_config = ForgeMirror::Util.read_yaml(config_file)
      # keys should all be symbols
      cli_options = ForgeMirror::Util.symbolize_keys(opts)
      # start by merging yaml config into default hash
      merged_config = ForgeMirror::Util.deep_safe_merge(@@default, yaml_config)
      # next iterate over cli options and merge the config into the
      # correct sub config hash
      cli_options.each do |k, v|
        merged_config.each do |key, sub|
          if sub.keys.include?(k)
            sub.merge!({k => v}) unless v.nil?
          end
        end
      end
      # finally create attr_accessors for each config option
      merged_config.each do |k,v|
        instance_variable_set("@#{k}", v)
        self.class.send(:attr_accessor, k)
      end
    end

    @@default = {
      github: {
        access_token: nil,
        organization: nil,
        internal_api_endpoint: 'https://api.github.com/'
      },
      general: {
        puppetfile_path: './Puppetfile',
        work_dir: '/tmp/modules',
        proxy: nil,
        config_file: './forgemirror_config.yaml'
      },
      git: {
        private_key: nil,
        public_key: nil
      }
    }

    def self.defaults
      @@default
    end

  end
end
