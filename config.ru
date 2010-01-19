require File.join(File.dirname(__FILE__),%w{config boot})

require 'tunejuggler'
set :app_file, ::File.expand_path(::File.dirname(__FILE__) + '/tunejuggler.rb')

run Sinatra::Application
