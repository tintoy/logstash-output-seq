# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/outputs/seq"
require "logstash/codecs/plain"
require "logstash/event"

# RSpec.configure do |config|

  # RSpec automatically cleans stuff out of backtraces;
  # sometimes this is annoying when trying to debug something e.g. a gem
  # if ENV['FULLBACKTRACES'] == 'true'
    # config.backtrace_exclusion_patterns = []
  # end

  # some other configuration here

# end

describe LogStash::Outputs::Seq do
  let(:sample_event) do
    return LogStash::Event.new({
      "host" => "localhost",
      "message" => "Hello"
    })
  end
  let(:output) { LogStash::Outputs::Seq.new }

  before do
    output.register
  end

  describe "receive message" do
    subject { output.receive(sample_event) }

    it "returns a string" do
      puts "Sample Event: #{sample_event.to_s}"

      expect(subject).to eq("Event received")
    end
  end
end
