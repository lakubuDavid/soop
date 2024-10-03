require "colorful"

require "./scafold"
begin
  Scafold.run
rescue ex
  puts "Error : #{ex.message}".red
end
