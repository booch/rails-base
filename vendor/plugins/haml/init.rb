begin
  require 'haml'
  Haml.init_rails(binding)
rescue LoadError
  puts 'HAML gem not installed. Please install it.'
end 
