require "commander"
# require "toml"
require "./language_initializer"
require "./config"
class Scafold
  VERSION   = "0.1.0"
  TOOL_NAME = "soop"

  def self.run
    # config = ScafoldConfig.parse_file("config.toml")
    # config = TOML::Config.parse_file("config.toml")
    config = SoopConfigs.configure
    # config = TOML.parse_file("config.toml")

    cli = Commander::Command.new do |cmd|
      cmd.use = TOOL_NAME
      cmd.long = "A small tool to initialize projects and generate runners for various languages."

      cmd.run do |options, arguments|
        puts cmd.help
      end
      cmd.commands.add do |cmd|
        cmd.use = "list"
        cmd.short = "List available recepies."
        cmd.long = cmd.short

        cmd.run do |options, arguments|
          puts ""
          
          config.keys.each do |key|
            line = "• #{key} "
            value = config[key]
            description = value.as_h["description"]?.try(&.as_s) || ""
            spacing = " " * (20 - key.size)
            puts "• #{key}#{spacing}: #{description}"
          end
          puts ""
        end
      end
      cmd.commands.add do |cmd|
        cmd.use = "brew <flags>"
        cmd.short = "Create a new project."
        cmd.long = cmd.short

        cmd.flags.add do |flag|
          flag.name = "language"
          flag.short = "-l"
          flag.long = "--language"
          flag.default = ""
          flag.description = "The programming language for the project."
        end

        cmd.flags.add do |flag|
          flag.name = "name"
          flag.short = "-n"
          flag.long = "--name"
          flag.default = ""
          flag.description = "The name of the project."
        end

        cmd.run do |options, arguments|
          language = options.string["language"]
          name = options.string["name"]

          if language.nil? || language.empty?
            puts "Error: Language is required."
            puts cmd.help
            exit(1)
          end
          if name.nil? || name.empty?
            puts "Error: Project name is required."
            puts cmd.help
            exit(1)
          end

          if config.has_key? language
            lang_config = config[language].as_h
            # puts lang_config
            LanguageInitializer.initialize_project(lang_config, language, name)
          else
            puts "Unknown template: #{language}"
            exit(1)
          end
        end
      end
    end

    Commander.run(cli, ARGV)
  end
end
