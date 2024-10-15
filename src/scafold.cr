require "commander"
require "colorful"

require "./language_initializer"
require "./config"

class Scafold
  VERSION   = "0.1.0"
  TOOL_NAME = "soop"

  def self.run
    config = SoopConfigs.configure

    cli = Commander::Command.new do |cmd|
      cmd.use = TOOL_NAME
      cmd.long = "A small tool to initialize projects and generate runners for various languages."

      cmd.flags.add do |flag|
        flag.name = "config"
        flag.short = "-c"
        flag.long = "--config"
        flag.default = ""
        flag.description = "The default path for the custom vonfig."
      end

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
            value = config[key]
            puts "• #{key} : ".cyan
            puts "  - Description: #{value.as_h["description"]?.try(&.as_s) || " - None - "} " # "
            status = LanguageInitializer.get_lang_status(value.as_h, key)
            print "   - Status : "
            if status == 0
              print " Ok\n".green
            elsif status == -1
              print " Failed check\n".red
            else
              print " Unknown\n".yellow
            end
          end
        end
      end
      cmd.commands.add do |cmd|
        cmd.use = "make <flags>"
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

        cmd.flags.add do |flag|
          flag.name = "output"
          flag.short = "-o"
          flag.long = "--output"
          flag.default = ""
          flag.description = "The output path for the project."
        end

        cmd.run do |options, arguments|
          language = options.string["language"]
          name = options.string["name"]
          output_path = options.string["output"]

          if language.nil? || language.empty?
            puts " Error: Language is required.".red
            puts cmd.help
            exit(1)
          end
          if name.nil? || name.empty?
            puts " Error: Project name is required.".red
            puts cmd.help
            exit(1)
          end

          if config.has_key? language
            lang_config = config[language].as_h
            LanguageInitializer.initialize_project(lang_config, language, name, output_path)
          else
            puts "Unknown template: #{language}".red
            exit(1)
          end
        end
      end
    end

    Commander.run(cli, ARGV)
  end
end
