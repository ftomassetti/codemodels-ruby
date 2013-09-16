# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.platform    = 'java'
  s.name        = 'ruby-lightmodels'
  s.version     = '0.1.4'
  s.date        = '2013-09-03'
  s.summary     = "Ruby metamodel and parser"
  s.description = "Ruby metamodel and parser producing an EMF model"
  s.authors     = ["Federico Tomassetti"]
  s.email       = 'f.tomassetti@gmail.com'
  s.homepage    = 'http://federico-tomassetti.it'
  s.license     = "APACHE2"

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_dependency('json')
  s.add_dependency('emf_jruby')
  s.add_dependency('jruby-parser', '=0.5.0')
  s.add_dependency('lightmodels')
  s.add_dependency('java-lightmodels')
  s.add_dependency('rgen')

  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency "rake"
  s.add_development_dependency "rubygems-tasks"
end