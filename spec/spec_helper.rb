require 'pp'
require 'fileutils'
ENV["RACK_ENV"] ||= "test"
require ::File.join(::File.dirname(__FILE__),"..","config","boot")
set :environment, :test
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
test_db = File.join(File.dirname(__FILE__),%w{.. db test.db})
FileUtils.rm test_db if File.exists?(test_db)

def log(msg)
end

