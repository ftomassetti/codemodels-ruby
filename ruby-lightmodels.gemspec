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
  s.files       = Dir['./lib/*.rb'] + Dir['./lib/rubylm/*.rb'] + Dir['./lib/jars/*.jar']
  s.add_dependency('json')
  s.add_dependency('emf_jruby')
  s.add_dependency('jruby-parser')
  s.add_dependency('lightmodels')
end