# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = "hash_mapper"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Łukasz Strzałkowski"]
  s.email       = ["lukasz.strzalkowski@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/hash_mapper"
  s.summary     = "Parsing hashes made simple"
  s.description = "Ruby DSL for parsing hashes"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "hash_mapper"

  s.add_development_dependency "activesupport", ">= 3.0.0"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rspec", ">= 2.0.0.rc"
  s.add_development_dependency "mocha", ">= 0.9.8"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
