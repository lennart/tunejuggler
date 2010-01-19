relative_path = lambda do |relative_path_parts|
  ::File.join(::File.dirname(__FILE__),*relative_path_parts)
end
require relative_path.call(%w{config boot})
require 'fileutils'
require 'resque/tasks'
require 'cucumber/rake/task'

namespace :app do
  desc "Create Standard Folders" 
  task :defaults do
    %w{db tmp log public}.each do |dir|
      FileUtils.mkdir_p relative_path.call(dir), :verbose => true unless File.exists?(dir)
    end
  end
end

namespace :index do
  desc "Clear Index"
  task :clear => :"app:defaults" do
    FileUtils.rm_rf relative_path.call(%w{tmp ferret}), :verbose => true
  end
end

namespace :db do
  desc "Drop database"
  task :drop => :"app:defaults" do
    Dir[relative_path.call(%w{db *.db})].each do |db|
      FileUtils.rm db, :verbose => true
    end
  end
end

desc "Reset to blank slate"
task :reset => [:"db:drop",:"index:clear"] do
  puts "Complete"
end

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format pretty -b"
end
