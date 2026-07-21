# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'my_api_client/version'

Gem::Specification.new do |spec|
  spec.name          = 'my_api_client'
  spec.version       = MyApiClient::VERSION
  spec.authors       = ['ryz310']
  spec.email         = ['ryz310@gmail.com']

  spec.summary       = 'The framework of Web API Client'
  spec.description   = 'Provides features error handling, retrying and so on.'
  spec.homepage      = 'https://github.com/ryz310/my_api_client'
  spec.license       = 'MIT'

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^spec/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.2.0'

  spec.add_dependency 'activesupport', '>= 7.2.0'
  spec.add_dependency 'faraday', '>= 0.17.1'
  spec.add_dependency 'jsonpath'
  spec.add_dependency 'sawyer', '>= 0.8.2'

  spec.add_development_dependency 'bundler', '>= 2.0'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'rubocop-rspec_rails'
  spec.add_development_dependency 'simplecov', '0.22.0'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'yard'
  spec.metadata = {
    'rubygems_mfa_required' => 'true',
  }
end
