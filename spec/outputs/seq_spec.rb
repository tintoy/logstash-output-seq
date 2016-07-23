# encoding: utf-8
require 'logstash/devutils/rspec/spec_helper'
require 'logstash/outputs/seq'
require 'logstash/codecs/plain'
require 'logstash/event'

require "sinatra"

PORT = rand(65535-1024) + 1025

# Enable access to request tokens from the test.
class LogStash::Outputs::Seq
  attr_reader :request_tokens
end

describe LogStash::Outputs::Seq do
  let(:sample_event) {
    LogStash::Event.new({
      'host' => 'localhost',
      'message' => 'Hi, Single Event'
    })
  }
  let(:sample_events) {
    [
      LogStash::Event.new({
        'host' => 'localhost',
        'message' => 'Hello, World.',
        'name' => 'World'
      }),
      LogStash::Event.new({
        'host' => 'localhost',
        'message' => 'Goodbye Moon',
        'name' => 'Moon'
      })
    ]
  }
  let(:output) {
    LogStash::Outputs::Seq.new({
      'url' => 'https://my-seq/',
      'api_key' => 'my-api-key',
      'ssl_certificate_validation' => false,
      'pool_max' => 1
    })
  }

  before do
    output.register
  end

  describe 'receive message' do
    subject { output.receive(sample_event) }

    it 'returns a string' do
      expect(subject).to eq('Event received')

      output.request_tokens.pop
    end
  end

  describe 'receive messages' do
    subject { output.multi_receive(sample_events) }

    it 'returns a string' do
      expect(subject).to eq('2 events received')

      output.request_tokens.pop
    end
  end
end
