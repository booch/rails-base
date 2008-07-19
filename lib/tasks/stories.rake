require 'rake'

namespace :spec do
  desc 'Run the stories / acceptance tests'
  task :acceptance do
    sh 'ruby stories/all.rb --format plain'
  end
end

