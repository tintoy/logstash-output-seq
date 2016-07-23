# encoding: utf-8
require 'json/ext'
require 'logstash/outputs/base'
require 'logstash/plugin_mixins/http_client'
require 'logstash/json'
require 'logstash/namespace'

# An output that sends events to Seq.
class LogStash::Outputs::Seq < LogStash::Outputs::Base
  include LogStash::PluginMixins::HttpClient

  @@ignore_properties = {
      '@timestamp' => true,
      '@level' => true,
      '@version' => true,
      'message' => true
  }
  
  config_name 'seq'

  # The Seq server URL
  config :url, :validate => :string, :required => :true

  # The Seq API key
  config :api_key, :validate => :string, :optional => :true

  public
  def register
    url = @url

    url += '/' unless url.end_with? '/'
    url += 'api/events/raw'

    @url = url

    @default_headers = {
        'X-Seq-ApiKey' => @api_key,
        'Content-Type' => 'application/json'
    }

    # We count outstanding requests with this queue; it tracks outstanding requests to create backpressure
    # When this queue is empty no new requests may be sent, tokens must be added back by the client on success
    @request_tokens = SizedQueue.new(@pool_max)
    @pool_max.times {|t| @request_tokens << true }
  end # def register

  public
  def multi_receive(events)
    payload = {
        'Events' => events.map {|event| to_seq_payload(event)}
    }
    post_to_seq(payload)

    "#{events.length} events received"
  end # def multi_receive

  public
  def receive(event)
    payload = {
        'Events' => [to_seq_payload(event)]
    }
    post_to_seq(payload)

    'Event received'
  end # def receive

  private
  def post_to_seq(payload)
    token = @request_tokens.pop

    request = client.post(@url, {
      headers: @default_headers,
      body:    payload.to_json,
      async:   true
    })

    request.on_complete do
      @request_tokens << token
    end

    request.on_success do |response|
      if response.code < 200 || response.code > 299
        log_failure("Encountered non-200 HTTP code #{200}",
          :response_code => response.code,
          :url => url,
          :event => event
        )
      end
    end

    request.on_failure do |exception|
      log_failure("Could not submit POST request.",
        :url => url,
        :method => @http_method,
        :body => body,
        :headers => headers,
        :message => exception.message,
        :class => exception.class.name,
        :backtrace => exception.backtrace
      )
    end

    request_async_background(request)
  end # def post_to_seq

  # Convert a Logstash event to a Seq event payload.
  #
  # Note that we return a hash here, not the JSON, because it's more efficient to convert batched events to JSON all-in-one go.
  private
  def to_seq_payload(event)
    props = {
        '@Version' => event['@version']
    }
    payload = {
        :Timestamp => event['@timestamp'],
        :Level => get_level(event),
        :MessageTemplate => event['message'],
        :Properties => props
    }

    event.instance_variable_get(:@data).each do |property, value|
      props[property] = value unless @@ignore_properties.has_key? property
    end

    payload
  end # def to_seq_payload

  private
  def get_level(event)
    level = event['@level']

    level ? level : 'Verbose'
  end # def get_level

  # Manticore doesn't provide a way to attach handlers to background or async requests well
  # It wants you to use futures. The #async method kinda works but expects single thread batches
  # and background only returns futures.
  # Proposed fix to manticore here: https://github.com/cheald/manticore/issues/32
  private
  def request_async_background(request)
    @method ||= client.executor.java_method(:submit, [java.util.concurrent.Callable.java_class])
    @method.call(request)
  end
end # class LogStash::Outputs::Seq
