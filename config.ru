require File.join(File.dirname(__FILE__),%w{config boot})
FileUtils.mkdir_p 'log' unless ::File.exists?('log')
log = ::File.new("log/sinatra.log", "a+")
$stdout.reopen(log)
$stderr.reopen(log)

require 'tunejuggler'
set :app_file, ::File.expand_path(::File.dirname(__FILE__) + '/tunejuggler.rb')

run Sinatra::Application
# vim:filetype=ruby
