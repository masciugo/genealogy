# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'genealogy/version'

Gem::Specification.new do |s|
  s.name          = "genealogy"
  s.version       = Genealogy::VERSION
  s.authors       = ["masciugo"]
  s.email         = ["masciugo@gmail.com"]
  s.homepage      = "https://github.com/masciugo/genealogy"
  s.summary       = "Make ActiveRecord model act as a pedigree"
  s.description   = "Genealogy is a ruby gem library which extends ActiveRecord models in order to make its instances act as relatives so that you can build and query genealogies"

  s.files         = `git ls-files app lib`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.date        = Time.now
  s.licenses    = ["MIT"]

  s.add_dependency('activerecord', '> 5.0')
  s.add_dependency('activesupport', '> 5.0')

  s.add_development_dependency 'sqlite3', '~> 1.4.1'
  s.add_development_dependency 'mysql2'
  s.add_development_dependency 'pg', '~> 1.0'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rspec-its'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'redcarpet'
  s.add_development_dependency 'github-markup'
  s.add_development_dependency 'gem-release'
  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'byebug'


end
