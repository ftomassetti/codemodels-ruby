Gem::Specification.new do |s|
  s.platform    = 'java'
  s.name        = 'rubymm'
  s.version     = '0.1.2'
  s.date        = '2013-08-15'
  s.summary     = "Ruby metamodel and parser"
  s.description = "Ruby metamodel and parser producing an EMF model"
  s.authors     = ["Federico Tomassetti"]
  s.email       = 'f.tomassetti@gmail.com'
  s.homepage    = 'http://federico-tomassetti.it'
  s.files       = Dir['./lib/*.rb'] + Dir['./lib/rubymm/*.rb'] + Dir['./lib/jars/*.jar']
  s.add_dependency('json')
  s.add_dependency('emf_jruby')
  s.add_dependency('jruby-parser')
end