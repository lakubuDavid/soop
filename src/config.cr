# require "toml-config"
require "totem"

struct LanguageConfig
end
struct SoopConfigs
  include Totem::ConfigBuilder

  # property command : String
  # property description : String
  # property source : String
  
  # property check : String
  
  # property mkdir : Bool
  
  # property justfile_path : String
  # property dockerfile_path : String
  # property source_path : String

  build do
    config_type "yaml"
    config_paths ["/etc/soop", "~/.config/soop", "./"]
  end
end
