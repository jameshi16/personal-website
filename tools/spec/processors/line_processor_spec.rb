require './common/processors/line_processor'
require './common/processors/date_metadata_line_processor'

include RSpec
shared_examples "line processor" do
  it { is_expected.to respond_to(:process).with(2).argument }
end

describe DateMetadataLineProcessor.new nil do
  it_behaves_like "line processor"
end

describe ImageDateLineProcessor.new(nil, nil) do
  it_behaves_like "line processor"
end
