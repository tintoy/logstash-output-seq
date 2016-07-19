# encoding: utf-8
require "logstash/outputs/base"
require "logstash/plugin_mixins/http_client"
require "logstash/namespace"

# An output that sends events to Seq.
class LogStash::Outputs::Seq < LogStash::Outputs::Base
  include LogStash::PluginMixins::HttpClient
  
  config_name "seq"

  # The Seq server URL
  config :url, :validate => :string, :required => :true

  # The Seq API key
  config :api_key, :validate => :string, :optional => :true

  public
  def register
  	# TODO: Implement.
  end # def register

  public
  def multi_receive(events)
  	# TODO: Implement.
  end # def multi_receive

  public
  def receive(event)
  	# TODO: Implement.

    return "Event received"
  end # def event
end # class LogStash::Outputs::Seq
