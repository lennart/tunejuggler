relative_path = lambda do |relative_path_parts|
  ::File.join(::File.dirname(__FILE__),*relative_path_parts)
end
require relative_path.call(%w{config boot})
require 'fileutils'
require 'resque/tasks'

namespace :index do
  desc "Clear Index"
  task :clear do
    FileUtils.rm_rf relative_path.call(%w{tmp ferret}), :verbose => true
  end
end

namespace :db do
  desc "Drop database"
  task :drop do
    FileUtils.rm relative_path.call(%w{db development.db}), :verbose => true
  end
end

desc "Reset to blank slate"
task :reset => [:"db:drop",:"index:clear"] do
  puts "Complete"
end
