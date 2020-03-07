require './common/handlers/handler'
require './common/handlers/time_updater_handler'
require './common/processors/line_processor.rb'

include RSpec

shared_examples "handler" do
  it { is_expected.to respond_to(:handle) }
  it { is_expected.to respond_to(:do_process).with(2).argument }
  it { is_expected.to respond_to(:append_processor).with(1).argument }
end  

describe Handler do
  h = Class.new do
    include Handler
  end.new

  it "calls the process function for each processors correctly" do
    mock_processor = instance_double(LineProcessor, :process => "yup it works")
    h.processors = [mock_processor]
    expect(h.do_process(1, "hmm")).to eq("yup it works")
  end
end

describe TimeUpdaterHandler.new("fakefile", nil, nil) do
  it_behaves_like "handler"
end
