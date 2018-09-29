# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'version-info'

Gem::Specification.new do |spec|
  spec.name          = 'logstash-output-seq'
  spec.version       = LogStash::Output::Seq::VERSION
  spec.licenses      = ["MIT"]
  spec.summary       = "This plugin outputs log entries to Seq (https://getseq.net)."
  spec.description   = "This gem is a Logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/logstash-plugin install logstash-output-seq. This gem is not a stand-alone program"
  spec.authors       = ["tintoy"]
  spec.email         = "tintoy@tintoy.io"
  spec.homepage      = "https://github.com/tintoy/logstash-output-seq"
  spec.require_paths = ["lib"]

  # Files
  spec.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE']
   # Tests
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  spec.metadata = { "logstash_plugin" => "true", "logstash_group" => "output" }

  # Gem dependencies
  spec.add_runtime_dependency "logstash-core", ">= 2.3.4", "<= 6"
  spec.add_runtime_dependency "logstash-mixin-http_client", ">= 2.2.4", "~> 6"
  spec.add_runtime_dependency "logstash-core-plugin-api", ">= 2.1.28", "<= 2.99"
  spec.add_runtime_dependency "logstash-codec-plain"

  spec.add_development_dependency "coveralls", "~> 0.8"
  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "logstash-devutils", "~> 0.0.15"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "rake", "~> 11.2"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "sinatra", "~> 1.4"
  spec.add_development_dependency "webrick", "~> 1.3"
end
