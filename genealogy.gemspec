# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'genealogy/version'

Gem::Specification.new do |s|
  s.name          = "genealogy"
  s.version       = Genealogy::VERSION
  s.authors       = ["masciugo"]
  s.email         = ["masciugo@gmail.com"]
  s.homepage      = "https://github.com//genealogy"
  s.summary       = "Organise ActiveRecord models into a genealogical tree structure"
  s.description   = "Genealogy is a ruby gem library which extend ActiveRecord::Base class with familiar relationships capabilities in order to build and query genealogies"

  s.files         = `git ls-files app lib`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.rubyforge_project = '[none]'
  s.date        = Time.now
  s.licenses    = ["MIT"]

  s.add_dependency 'activerecord'
  s.add_dependency 'activesupport'
  
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'debugger'
end
