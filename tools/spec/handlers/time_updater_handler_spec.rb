require 'time'

require './common/handlers/time_updater_handler'
require './common/processors/line_processor'

include RSpec

describe TimeUpdaterHandler do
  h = TimeUpdaterHandler.new("fakefile", nil, nil)

  describe "#get_blogfile_components" do
    it 'returns a path to the match' do
      filename = "./directory/2019-09-24-interesting-post.md"
      h = TimeUpdaterHandler.new(filename, nil, nil)
      
      expect(h.get_blogfile_components[1..3]).to eq(["./directory/", "2019-09-24", "interesting-post.md"])
    end
  end

  describe "#generate_new_filename" do
    time = Time.parse "2020-09-20 18:00:45 +0800"

    it "generates a new filename" do
      h = TimeUpdaterHandler.new("2019-09-17-hello-world.md", time, nil)
      expect(h.generate_new_filename).to eq("2020-09-20-hello-world.md")
    end

    it "does not generate a new filename" do
      h = TimeUpdaterHandler.new("hi", nil, nil)
      expect(h.generate_new_filename).to eq("hi")
    end

  end

  it "replaces strings correctly with one processor" do 

    begin
      tmp = Tempfile.new('toolstest')
      tmp.write "random string"
      tmp.close # relinquish control back to handler

      h = TimeUpdaterHandler.new(tmp.path, nil, nil)

      mock_processor = instance_double(LineProcessor, :process => "ok im quite sure it works")
      h.processors = [mock_processor]
      h.handle

      tmp.open
      expect(tmp.read).to eq("ok im quite sure it works")
    ensure
      tmp.close true
    end 

  end

  it "replaces strings correctly with two processors" do
    
    begin
      tmp = Tempfile.new('anothertoolstest')
      tmp.write "another random string"
      tmp.close # relinquish control back to handler

      h = TimeUpdaterHandler.new(tmp.path, nil, nil)

      mock_processor_1 = instance_double(LineProcessor, :process => "first string")
      mock_processor_2 = instance_double(LineProcessor, :process => "second string")
      h.processors = [mock_processor_1, mock_processor_2]
      h.handle

      tmp.open
      expect(tmp.read).to eq("second string") 
    ensure
      tmp.close true
    end

  end

end
