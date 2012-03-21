# -*- encoding: utf-8 -*-
 
Gem::Specification.new do |s|
  s.name = 'saxaphone'
  s.version = '0.5.0'
  s.summary = 'Object Oriented SAX Parsing'
  s.description = 'Use objects'

  s.required_ruby_version     = '>= 1.8.7'
  s.required_rubygems_version = '>= 1.3.5'

  s.author            = 'Matthew Higgins'
  s.email             = 'developer@matthewhiggins.com'
  s.homepage          = 'http://github.com/matthuhiggins/saxaphone'

  s.extra_rdoc_files = ['README.rdoc']
  s.files = %w(MIT-LICENSE Rakefile README.rdoc) + Dir['{lib,test}/**/*.rb']
  s.require_path = 'lib'
  s.add_dependency 'nokogiri'
end