# encoding: utf-8
require 'logstash/devutils/rspec/spec_helper'
require 'logstash/outputs/seq'
require 'logstash/codecs/plain'
require 'logstash/event'

require "json"
require "sinatra"

describe LogStash::Outputs::Seq do
  # Output and its configuration
  let(:port) { PORT }
  let(:url) { "http://localhost:#{port}/" }
  let(:output) {
    LogStash::Outputs::Seq.new({
      'url' => url,
      'pool_max' => 1 # Required so we can block until the request completes.
    })
  }

  # Captured request
  let(:request_failed) { TestApp.last_request_failed }
  let(:last_request) { TestApp.last_request }
  let(:request_body) { last_request.body.read }
  let(:request_content_type) { last_request ? last_request.env["CONTENT_TYPE"] : nil }
  let(:posted_events) { JSON.parse(request_body) }

  # Sample events
  let(:sample_event) {
    LogStash::Event.new({
      '@timestamp' => '2016-07-23T10:09:08.12345+10:00',
      'host' => 'localhost',
      'message' => 'Hi, Single Event'
    })
  }
  let(:sample_events) {
    [
      LogStash::Event.new({
        '@timestamp' => '2016-07-23T00:09:08.123Z',
        '@level' => 'Info',
        'host' => 'localhost',
        'message' => 'Hello, World!',
        'name' => 'World'
      }),
      LogStash::Event.new({
        '@timestamp' => '2016-07-23T00:09:00.456Z',
        '@level' => 'Warning',
        'host' => 'localhost',
        'message' => 'Goodbye Moon?',
        'name' => 'Moon'
      })
    ]
  }

  before do
    TestApp.reset
  end

  before do
    output.register
  end

  describe 'receive message' do
    before do
      output.receive(sample_event)
      wait_for_request
    end

    it 'makes a request' do
      expect(last_request).to_not be_nil
    end

    it 'does an HTTP POST' do
      expect(request_failed).to be(false)
    end

    it 'sends JSON' do
      expect(request_content_type).to eq('application/json')
    end

    it 'sends a valid event event data payload' do
      expect(posted_events).to eq(
          {
              'Events' => [
                  {
                      'Timestamp' => '2016-07-23T00:09:08.123Z',
                      'Level' => 'Verbose',
                      'MessageTemplate' => 'Hi, Single Event',
                      'Properties' => {
                          '@Version' => "1",
                          'host' => 'localhost'
                      }
                  }
              ]
          }
      )
    end
  end

  describe 'receive messages' do
    before do
      output.multi_receive(sample_events)
      wait_for_request
    end

    it 'makes a request' do
      expect(last_request).to_not be_nil
    end

    it 'does an HTTP POST' do
      expect(request_failed).to be(false)
    end

    it 'sends JSON' do
      expect(request_content_type).to eq('application/json')
    end

    it 'sends a valid event event data payload' do
      expect(posted_events).to eq(
          {
              'Events' => [
                  {
                      'Timestamp' => '2016-07-23T00:09:08.123Z',
                      'Level' => 'Info',
                      'MessageTemplate' => 'Hello, World!',
                      'Properties' => {
                          '@Version' => "1",
                          'host' => 'localhost',
                          'name' => 'World'
                      }
                  },
                  {
                      'Timestamp' => '2016-07-23T00:09:00.456Z',
                      'Level' => 'Warning',
                      'MessageTemplate' => 'Goodbye Moon?',
                      'Properties' => {
                          '@Version' => "1",
                          'host' => 'localhost',
                          'name' => 'Moon'
                      }
                  }
              ]
          }
      )
    end
  end

  def wait_for_request()
    # Wait for the current request to complete.
    output.request_tokens.pop
  end
end

# Enable access to request tokens from the test.
class LogStash::Outputs::Seq
  attr_reader :request_tokens
end

PORT = rand(65535-1024) + 1025

RSpec.configure do |config|
  #http://stackoverflow.com/questions/6557079/start-and-call-ruby-http-server-in-the-same-script
  def sinatra_run_wait(app, opts)
    queue = Queue.new

    Thread.new(queue) do |queue|
      begin
        app.run!(opts) do |server|
          queue.push("started")
        end
      rescue
        # ignore
      end
    end

    queue.pop # blocks until the run! callback runs
  end

  config.before(:suite) do
    sinatra_run_wait(TestApp, :port => PORT, :server => 'webrick')
  end
end

# note that Sinatra startup and shutdown messages are directly logged to stderr so
# it is not really possible to disable them without reopening stderr which is not advisable.
#
# == Sinatra (v1.4.6) has taken the stage on 51572 for development with backup from WEBrick
# == Sinatra has ended his set (crowd applauds)

class TestApp < Sinatra::Base

  # disable WEBrick logging
  def self.server_settings
    { :AccessLog => [], :Logger => WEBrick::BasicLog::new(nil, WEBrick::BasicLog::FATAL) }
  end

  def self.reset()
    @last_request_failed = false
    @last_request = nil
  end

  def self.last_request_failed=(last_request_failed)
    @last_request_failed = last_request_failed
  end

  def self.last_request_failed
    @last_request_failed
  end

  def self.last_request=(request)
    @last_request = request
  end

  def self.last_request
    @last_request
  end

  def self.multiroute(methods, path, &block)
    methods.each do |method|
      method.to_sym
      self.send method, path, &block
    end
  end

  post "/api/events/raw" do
    self.class.last_request = request
    # Success after failure stills means failure until reset

    [200, '{"MinimumLevelAccepted": null}']
  end

  multiroute(%w(get post put patch delete), "/*") do
    self.class.last_request = request
    self.class.last_request_failed = true

    [500, "{\"Error\": \"Unexpected request: #{request.request_method} '#{request.url}'\"}"]
  end
end
