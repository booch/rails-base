begin
  require 'rubygems'
  require 'haml'
  require 'haml/template'
  require 'sass'
  require 'sass/plugin'
  
  ActionView::Base.register_template_handler('haml', Haml::Template)
  Sass::Plugin.update_stylesheets
rescue LoadError
  puts 'HAML gem not installed. Please install it.'
end
