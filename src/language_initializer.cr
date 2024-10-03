require "file_utils"
require "colorful"

# require

class LanguageInitializer
  def self.validate_config(config : Hash)
    if !config.has_key? ("command") || !(config.has_key? "source" && config.has_key? "source_path")
      return false
    end
    # [].each do |property|
    #   if ! config.has_key? property
    #     return false
    #   end
    # end
    return true
  end

  # 1  : Unknown
  # 0  : Ok
  # -1 : Failed
  def self.get_lang_status(config : Hash,language : String)
    begin
    if config.has_key?("check")
      (`where #{config["check"]}`)
      if $?.exit_code == 0
        return 0
      else
        return -1
      end
    else
    puts "   - Warning : No check set".yellow
      1
    end
    rescue ex
    puts "   - Error during check : #{ex.message}".red
    1
    end
  end
  def self.initialize_project(config : Hash, language : String, name : String)
    begin
      puts "➤ Initializing #{language} project: #{name}\n".green
      error = false
      if config.has_key?("mkdir") && config["mkdir"].as_bool
        Dir.mkdir_p(name)
        puts "➤ Created new directory #{name}".cyan
      end

      # TODO: Check for dependencies

      if config.has_key?("command")
        puts "➤ Scafolding project".cyan
        # Run init command
        command = config["command"].as_s.gsub("{name}", name)
        error = !system(command)
        if error
          puts "✖︎ Error when executing command \"#{config["command"]}\"".red
          return
        end
        puts "➤ Project generated".cyan
      elsif config.has_key?("source") && config.has_key?("source_path")
        source = config["source"]
        source_path = config["source_path"]
        # puts "➤ Adding source file #{source}"
        source_content = File.read(source_path.as_s)
        source_content = source_content.gsub("{name}", name)

        File.write(File.join(name, source.as_s), source_content)
        puts "➤ Source file added".cyan
      end

      # Generate Justfile if present
      if config.has_key? "justfile_path"
        justfile_path = config["justfile_path"]
        justfile_content = File.read(justfile_path.as_s)
        justfile_content = justfile_content.gsub("{name}", name)

        File.write(File.join(name, "Justfile"), justfile_content)

        puts "➤ Generated Justfile".cyan
      end

      # Generate Dockerfile
      if config.has_key? "dockerfile_path"
        dockerfile_path = config["dockerfile_path"]
        dockerfile_content = File.read(dockerfile_path.as_s)
        dockerfile_content = dockerfile_content.gsub("{name}", name)

        File.write(File.join(name, "Dockerfile"), justfile_content)

        puts "➤ Generated Dockerfile".cyan
      end

      puts "\n✔︎ Project initialized successfully! ✨".green
    rescue ex
      puts "\n✖︎ An error happened : \n\t#{ex.message}".red
    end
  end
end
