# require "toml-config"
require "totem"

struct LanguageConfig
end

struct SoopConfigs
  include Totem::ConfigBuilder

  build do
    config_type "yaml"
    config_paths ["/etc/soop/", Path["~/.config/soop/"].expand(home: true).to_s, "./"]
  end
end
