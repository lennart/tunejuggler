ENV["RACK_ENV"] = "integration"
require File.join(File.dirname(__FILE__), *%w{.. .. config boot})
Bundler.require_env :integration
Sinatra::Application.set :environment, :integration
app_file = File.join(File.dirname(__FILE__), *%w{.. .. tunejuggler.rb}) 
require app_file
require 'factory_girl/step_definitions'
Sinatra::Application.app_file = app_file
ENV["VERBOSE"] = "yes"

require 'spec/expectations'
class MyWorld
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
end

World{MyWorld.new}
