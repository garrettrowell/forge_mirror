require 'deep_merge'

module ForgeMirror
  class Util
    def self.read_yaml(conf_file)
      YAML.safe_load(File.open(File.expand_path(conf_file)).read, symbolize_names: true)
    end

    def self.symbolize_keys(hash)
      hash.inject({}){|result, (key, value)|
        new_key = case key
                  when String then key.to_sym
                  else key
                  end
        new_value = case value
                    when Hash then symbolize_keys(value)
                    else value
                    end
        result[new_key] = new_value
        result
      }
    end

    # Merges new_hash into source_hash, without modifying arguments, but
    # will merge nested arrays and hashes too. Also will NOT merge nil or blank
    # from new_hash into old_hash
    def self.deep_safe_merge(source_hash, new_hash)
      source_hash.merge(new_hash) do |key, old, new|
        if new.respond_to?(:blank) && new.blank?
          old
        elsif (old.kind_of?(Hash) and new.kind_of?(Hash))
#          deep_merge(old, new)
          old.deep_merge(new)
        elsif (old.kind_of?(Array) and new.kind_of?(Array))
          old.concat(new).uniq
        else
          new
        end
      end
    end
  end
end
