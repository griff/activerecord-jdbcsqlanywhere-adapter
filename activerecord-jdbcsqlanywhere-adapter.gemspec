# -*- encoding: utf-8 -*-
require File.expand_path("../lib/activerecord-jdbcsqlanywhere-adapter", __FILE__)

Gem::Specification.new do |s|
  s.name        = "activerecord-jdbcsqlanywhere-adapter"
  s.version     = ArJdbc::SybaseSQLAnywhere::VERSION
  s.author      = 'Brian Olsen'
  s.email       = 'brian@maven-group.org'
  s.homepage    = "http://github.com/griff/activerecord-jdbcsqlanywhere-adapter"
  s.summary     = "Sybase SQLAnywhere JDBC adapter for JRuby on Rails"
  s.description = "Install this gem to use Sybase SQLAnywhere with JRuby on Rails"

  s.required_rubygems_version = ">= 1.3.6"

  s.add_dependency('activerecord-jdbc-adapter', "~> 1.1.1")
  s.add_development_dependency "bundler", ">= 1.0.0"

  s.files        = `git ls-files`.split("\n") << 'lib/arjdbc/sqlanywhere/adapter_java.jar'
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
