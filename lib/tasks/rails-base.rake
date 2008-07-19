require 'rake'

namespace :rails do
  desc 'Set project name in database names and session_key; specify NAME, or default to enclosing dir name.'
  task :rename do
    PROJECT = ENV['NAME'] || File.basename(Dir.pwd)
    %w(development test production staging).each do |env|
      %x{sed -i -e "s/^  database: .*_#{env}$/  database: #{PROJECT}_#{env}/" config/database.yml}
    end
    %x{sed -i -e "s/:session_key => '.*'/:session_key => '_#{PROJECT}_session'/" config/environment.rb}
  end

  desc 'Reset secret keys used to encrypt session data and protect from CSRF.'
  task :secret do
    SECRET = %x{rake -s secret}.chomp
    %x{sed -i -e "s/:secret      => '.*'/:secret =>      '#{SECRET}'/" config/environment.rb}
    SECRET2 = %x{rake -s secret}[1..32]
    %x{sed -i -e "s/protect_from_forgery :secret => '.*'/protect_from_forgery :secret => '#{SECRET2}'/" app/controllers/application.rb}
  end
end
