# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crud_model/version'

Gem::Specification.new do |gem|
  gem.name          = "crud_model"
  gem.version       = CrudModel::VERSION
  gem.authors       = ["HORII Keima"]
  gem.email         = ["holysugar@gmail.com"]
  gem.description   = %q{CrudModel makes easy to create model class for rails scaffold form.}
  gem.summary       = %q{CrudModel}
  gem.homepage      = "https://github.com/holysugar/crud_model"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  # TODO: version 4 support?
  gem.add_dependency 'activesupport'
  gem.add_dependency 'activemodel'
end
