require "file_utils"
require "colorful"

class LanguageInitializer
  def self.get_path(path : String)
    xdg_path = Path["~/.config/soop/#{path}"].expand(home: true)
    current_path = Path["./#{path}"].expand(home: true)
    etc_path = Path["/etc/soop/#{path}"].expand(home: true)
    if File.file? current_path
      return current_path
    elsif File.file? xdg_path
      return xdg_path
    elsif File.file? etc_path
      return etc_path
    end
    path
  end

  def self.validate_config(config : Hash)
    return true
  end

  # 1  : Unknown
  # 0  : Ok
  # -1 : Failed
  def self.get_lang_status(config : Hash, language : String)
    begin
      if config.has_key?("check")
        (`which #{config["check"]}`)
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

  def self.generate_file(config : Hash, key : String, name : String, default_name : String, output_path : String)
    if config.has_key?("#{key}_path")
      file_path = config["#{key}_path"].as_s
      content = File.read(get_path file_path).gsub("{name}", name)
      File.write(File.join(output_path, name, default_name), content)
      puts "➤ Generated #{default_name}".cyan
    end
  end


  # # Then in your initialize_project method:
  # generate_file(config, "justfile", name, "Justfile")
  # generate_file(config, "dockerfile", name, "Dockerfile")

  def self.initialize_project(config : Hash, language : String, name : String,output_path : String)
    begin
      puts "➤ Initializing #{language} project: #{name}".green
      error = false
      work_dir = "output_path"
      _mk_dir = false

      if config.has_key?("mkdir") && config["mkdir"].as_bool
        Dir.mkdir_p(File.join(output_path, name))
        _mk_dir = true
        puts "➤ Created new directory #{name}".cyan
      end

      if self.get_lang_status(config, language) == -1
        puts "✖︎ Check failed for #{language},one of the dependencies must be missing : \"#{config["check"]}\"".red
      end

      if config.has_key?("command")
        puts "➤ Scafolding project".cyan
        # Run init command
        command = config["command"].as_s.gsub("{name}", name)
        error = false
        if _mk_dir
          error = !system("cd  #{File.join(output_path, name)} && " + command)
        else
          error = !system(command)
        end
        if error
          puts "✖︎ Error when executing command \"#{config["command"]}\"".red
          return
        end
        puts "➤ Project generated".cyan
      end
      
      if config.has_key?("source") && config.has_key?("source_path")
        source = config["source"]
        source_path = config["source_path"]
        # puts "➤ Adding source file #{source}"
        source_content = File.read(get_path source_path.as_s)
        source_content = source_content.gsub("{name}", name)

        File.write(File.join(output_path,name, source.as_s), source_content)
        puts "➤ Source file added".cyan
      elsif config.has_key?("sources") && config["sources"].as_h?
        sources = config["sources"].as_h
        sources.each do |source, source_path|
          puts "> Adding source file #{source}"
          source_content = File.read(get_path(source_path.as_s))
          source_content = source_content.gsub("{name}", name)
          File.write(File.join(output_path,name, source), source_content)
          puts "> Source file added".cyan
        end
      end


      generate_file(config, "justfile", name, "Justfile", output_path)
      generate_file(config, "dockerfile", name, "Dockerfile", output_path)

      # # Generate Justfile if present
      # if config.has_key? "justfile_path"
      #   justfile_path = config["justfile_path"]
      #   justfile_content = File.read(get_path justfile_path.as_s)
      #   justfile_content = justfile_content.gsub("{name}", name)

      #   File.write(File.join(name, "Justfile"), justfile_content)

      #   puts "➤ Generated Justfile".cyan
      # end

      # # Generate Dockerfile
      # if config.has_key? "dockerfile_path"
      #   dockerfile_path = config["dockerfile_path"]
      #   dockerfile_content = File.read(get_path dockerfile_path.as_s)
      #   dockerfile_content = dockerfile_content.gsub("{name}", name)

      #   File.write(File.join(name, "Dockerfile"), dockerfile_content)

      #   puts "➤ Generated Dockerfile".cyan
      # end

      puts "✔︎ Project ready! ✨".green
      if _mk_dir
        puts "    cd name && just to get started"
      end
    rescue ex
      puts "\n✖︎ An error happened : \n\t#{ex.message}".red
    end
  end
end
