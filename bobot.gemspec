$LOAD_PATH.push File.expand_path('../lib', __FILE__)

require 'bobot/version'

Gem::Specification.new do |s|
  s.name                      = 'bobot'
  s.version                   = Bobot::Version
  s.authors                   = ['Navid EMAD']
  s.email                     = ['contact@navidemad.net']
  s.summary                   = 'Facebook Messenger Bot'
  s.description               = 'Bobot is a Ruby wrapped framework to build easily a Facebook Messenger Bot.'
  s.homepage                  = 'https://github.com/navidemad/bobot'
  s.license                   = 'MIT'
  s.extra_rdoc_files          = ['MIT-LICENSE', 'README.md']
  s.required_ruby_version     = '>= 2.3.1'
  s.rdoc_options              = ['--charset=UTF-8']
  s.test_files                = Dir['spec/**/*']
  s.files                     = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  s.add_dependency            'i18n'
  s.add_dependency            'rails', ['>= 5', '< 6']
  s.add_dependency            'typhoeus'
end
