# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/outputs/seq"
require "logstash/codecs/plain"
require "logstash/event"

describe LogStash::Outputs::Seq do
  let(:sample_event) do
    return LogStash::Event.new({
      "host" => "localhost",
      "message" => "Hello Diddly"
    })
  end
  let(:sample_events) do
    return [
      LogStash::Event.new({
        "host" => "localhost",
        "message" => "Hello World"
      }),
      LogStash::Event.new({
        "host" => "localhost",
        "message" => "Goodbye Moon"
      }) 
    ]
  end
  let(:output) { LogStash::Outputs::Seq.new({"url" => "http://localhost:5432/"}) }

  before do
    output.register
  end

  describe "receive message" do
    subject { output.receive(sample_event) }

    it "returns a string" do
      puts "Sample Event: #{sample_event.to_json}"

      expect(subject).to eq("Event received")
    end
  end

  describe "receive messages" do
    subject { output.multi_receive(sample_events) }

    it "returns a string" do
      puts "Sample Events: #{sample_events.to_json}"

      expect(subject).to eq("2 events received")
    end
  end
end
