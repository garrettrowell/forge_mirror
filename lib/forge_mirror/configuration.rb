module ForgeMirror
  class Configuration
    # Merge configuration specified in file with current runtime config.
    # This will only overwrite if the existing config is a default value
    # as to allow cli options to take precedence over config_file values
    def self.merge_file(conf_file)
      yaml_config = ForgeMirror::Util.read_yaml(conf_file)
      yaml_config.each do |section, sub_hash|
        sub_hash.each do |k,v|
          old = ForgeMirror.configuration[section.to_sym][k.to_sym]
          ForgeMirror.configuration[section.to_sym][k.to_sym] = v if old == @@default[section.to_sym][k.to_sym]
        end
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
