require_relative './line_processor'

class DateMetadataLineProcessor
  include LineProcessor
  attr_accessor :time

  def initialize time
    @time = time
  end

  def self.is_date? line_str
    /[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2} \+[0-9]{2}:[0-9]{2}/.match? line_str
  end

  def self.is_date_metadata? line_str
    [DateMetadataLineProcessor.is_date?(line_str), /^date: .+\n/.match?(line_str)].all?
  end
  
  def gen_date
    @time.strftime("%Y-%m-%d %H:00 %:z")
  end

  def process(line_num, line)
    if DateMetadataLineProcessor.is_date_metadata? line    
      puts "date metadata found in #{line_num}"
      return "date: #{self.gen_date}\n"
    else
      return line
    end
  end

end
