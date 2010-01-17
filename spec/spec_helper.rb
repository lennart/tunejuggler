ENV["RACK_ENV"] ||= "test"
require ::File.join(::File.dirname(__FILE__),"..","config","boot")
set :environment, :test
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')

def log(msg)
end

