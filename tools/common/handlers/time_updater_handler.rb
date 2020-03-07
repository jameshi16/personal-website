require 'tempfile'
require 'time'

require_relative './handler'
require_relative '../processors/date_metadata_line_processor'
require_relative '../processors/image_date_line_processor.rb'

class TimeUpdaterHandler
  include Handler

  def initialize(filename, time, path)
    @time = time
    @path = path
    @processors = [DateMetadataLineProcessor.new(@time), ImageDateLineProcessor.new(@time, @path)] 
    @filename = filename
  end

  def get_blogfile_components 
    /([\s\S]*)([0-9]{4}-[0-9]{2}-[0-9]{2})-([\s\S]+)/.match(@filename)
  end

  def gen_date
    return @time.strftime("%Y-%m-%d")
  end

  def generate_new_filename
    data = self.get_blogfile_components 

    if data.nil? || data[3].nil?
      return @filename
    end

    return "#{data[1]}#{self.gen_date}-#{data[3]}"
  end

  def handle
    if not File.exist?(@filename)
      return
    end

    Tempfile.create('bp') { |tmp|
      IO.foreach(@filename).with_index { |line, line_num| 
        tmp.write self.do_process(line_num, line) 
      }

      tmp.rewind
      IO.copy_stream(tmp, @filename)
    }

    move_to = self.generate_new_filename
    if @filename != move_to # fileutils doesn't like same file moves
      FileUtils.mv(@path + @filename, @path + self.generate_new_filename, force: true)
    end
  end

  def append_processor arg
    @processors.push(arg)
  end

end
