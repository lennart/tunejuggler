unless Object.const_defined? :SINATRA_ROOT
  class String
    def blank?
      self.nil? || self.strip == ""
    end
  end

  class NilClass
    def blank?
      self.nil? || self == ""
    end
  end
  require File.expand_path(File.join(File.dirname(__FILE__),%w{.. vendor gems environment}))
  if ENV["RACK_ENV"]
    Bundler.require_env ENV["RACK_ENV"].to_sym
  else
    Bundler.require_env
  end

  $LOAD_PATH.unshift(::File.join(::File.dirname(__FILE__), *%w{.. lib}))
  SINATRA_ROOT=::File.expand_path(::File.join(::File.dirname(__FILE__),"..")) 
  INDEX_PATH=File.expand_path(File.join(File.dirname(__FILE__),%w{.. tmp ferret index}))
end

Dir[File.join(File.dirname(__FILE__),%w{.. lib ** *.rb})].each do |path|
  klass = File.basename(path,File.extname(path)).camelize.to_sym
  puts "Autloading #{klass} from #{path}"
  autoload klass, path
end
