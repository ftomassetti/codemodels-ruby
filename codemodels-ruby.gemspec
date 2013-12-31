# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.platform    = 'java'
  s.name        = 'codemodels-ruby'
  s.version     = CodeModels::Ruby::VERSOPM
  s.date        = '2013-12-31'
  s.summary     = "Plugin of codemodels to build models from Ruby code."
  s.description = "Plugin of codemodels to build models from Ruby code. See http://github.com/ftomassetti/codemodels."
  s.authors     = ["Federico Tomassetti"]
  s.email       = 'f.tomassetti@gmail.com'
  s.homepage    = 'https://github.com/ftomassetti/codemodels-ruby'
  s.license     = "APACHE 2"

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_dependency('json')
  s.add_dependency('jruby-parser', '=0.5.1')
  s.add_dependency('codemodels')
  s.add_dependency('codemodels-java')

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "rubygems-tasks"
  s.add_development_dependency "simplecov"
end
