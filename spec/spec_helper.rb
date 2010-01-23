require 'pp'
require 'fileutils'
ENV["RACK_ENV"] ||= "test"
require ::File.join(::File.dirname(__FILE__),"..","config","boot")
set :environment, :test
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')

def recreate_db
  Sinatra::Application.database.tables.each do |t|
    Sinatra::Application.database.drop_table t
  end
end

def log(msg)
end

