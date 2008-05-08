require 'rake'

namespace :git do
  desc 'Prepares for git commit'
  task :prepare do
    %x{rake stats    > doc/stats.txt }
    %x{rake spec:doc > doc/specs.txt }
    %x{rake routes   > doc/routes.txt }
    %x{rake notes    > doc/code-notes.txt }
    %x{git add doc/stats.txt doc/specs.txt doc/routes.txt doc/code-notes.txt }
  end
end

