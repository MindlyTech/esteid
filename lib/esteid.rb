$:.unshift(File.dirname(__FILE__)) unless begin
  $:.include?(File.dirname(__FILE__)) ||
  $:.include?(File.expand_path(File.dirname(__FILE__)))
end

require "rubygems"
require "esteid/version"
require "esteid/authentication"
require "esteid/validation"
