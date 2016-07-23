Gem::Specification.new do |s|
  s.name          = 'logstash-output-seq'
  s.version       = "0.0.1"
  s.licenses      = ["MIT"]
  s.summary       = "This plugin outputs log entries to Seq (https://getseq.net)."
  s.description   = "This gem is a Logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/logstash-plugin install gemname. This gem is not a stand-alone program"
  s.authors       = ["tintoy"]
  s.email         = "tintoy@tintoy.io"
  s.homepage      = "https://github.com/tintoy/logstash-output-seq"
  s.require_paths = ["lib"]

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "output" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core", ">= 2.3.4", "< 3.0.0"
  s.add_runtime_dependency "logstash-mixin-http_client", ">= 2.2.4", "< 3.0.0"
  s.add_runtime_dependency "logstash-codec-plain"

  s.add_development_dependency "logstash-devutils", "~> 0.0.15"
  s.add_development_dependency "sinatra"
  s.add_development_dependency "webrick"
end
