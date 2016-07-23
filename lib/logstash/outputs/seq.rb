# encoding: utf-8
require "json/ext"
require "logstash/outputs/base"
require "logstash/plugin_mixins/http_client"
require "logstash/namespace"

# An output that sends events to Seq.
class LogStash::Outputs::Seq < LogStash::Outputs::Base
  include LogStash::PluginMixins::HttpClient

  @@ignore_properties = {
    "@timestamp" => true,
    "@level" => true,
    "@version" => true,
    "message" => true
  }
  
  config_name "seq"

  # The Seq server URL
  config :url, :validate => :string, :required => :true

  # The Seq API key
  config :api_key, :validate => :string, :optional => :true

  public
  def register
    url = @url

    url += "/" unless url.end_with? "/"
    url += "api/events/raw"

    @url = url
  end # def register

  # AF: Something odd about scoping here, need to work out how to pass instance method to_payload to lambda used by events.map.

  public
  def multi_receive(events)
    payload = {
      "Events" => events.map {|event| to_seq_payload(event)}
    }
    payload = payload.to_json

    puts "Payload: #{payload}"

  	# TODO: Submit to Seq.

    return "#{events.length} events received"
  end # def multi_receive

  public
  def receive(event)
    payload = to_seq_payload(event)
    payload = payload.to_json

    puts "Payload: #{payload}"

  	# TODO: Submit to Seq.

    return "Event received"
  end # def receive

  # Convert a Logstash event to a Seq event payload.
  #
  # Note that we return a hash here, not the JSON, because it's more efficient to convert batched events to JSON all-in-one go.
  private
  def to_seq_payload(event)
    props = {}
    payload = {
      "@Version" => event["@version"],
      "Timestamp" => event["@timestamp"],
      "Level" => get_level(event),
      "MessageTemplate" => event["message"],
      "Properties" => props
    }

    event.instance_variable_get(:@data).each do |property, value|
      props[property] = value unless @@ignore_properties.has_key? property
    end

    return payload
  end # def to_seq_payload

  private
  def get_level(event)
    return event["@level"] if event["@level"] else "Debug"
  end
end # class LogStash::Outputs::Seq
