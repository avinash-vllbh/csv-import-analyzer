# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'csv-import-analyzer/version'

Gem::Specification.new do |spec|
  spec.name          = "csv-import-analyzer"
  spec.version       = CsvImportAnalyzer::Version::VERSION
  spec.authors       = ["avinash vallabhaneni"]
  spec.email         = ["avinash.vallab@gmail.com"]
  spec.description   = %q{Santize large csv files and help in predicting datatypes including min max values for easy import to SQL}
  spec.summary       = %q{To process large csv files and predict valid datatypes of each column for easy import into SQL}
  spec.homepage      = "http://rubygems.org/gems/csv-import-analyzer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov", "~> 0.9"
  
  spec.add_runtime_dependency "smarter_csv", "~> 1.0.17"
  spec.add_runtime_dependency "roo", "~> 1.13"
end
