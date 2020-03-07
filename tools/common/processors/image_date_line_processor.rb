require_relative './line_processor'

class ImageDateLineProcessor
  include LineProcessor
  attr_accessor(:time, :path)

  def self.has_dated_image? line_str
    /".*[0-9]{8}_\d+.(png|jpg|jpeg|gif|bmp)"/.match? line_str
  end

  def self.get_dated_image_path_from_line line_str
    if not has_dated_image? line_str
      return
    end

    path, date, seq, format = /"(.*)([0-9]{8})_(\d+).(png|jpg|jpeg|gif|bmp)"/.match(line_str)[1..4]
    return DatedImage.new(path: path, date: date, sequence: seq, format: format)
  end

  def gen_date
    return @time.strftime("%Y%m%d")
  end

  def initialize(time, path)
    @time = time
    @path = path
  end

  def process(line_num, line)
    result = ImageDateLineProcessor.get_dated_image_path_from_line line

    if result.nil?
      return line
    end

    # get a new date
    puts "found qualified image on line #{line_num}"
    new_date = result.dup
    new_date.date = self.gen_date

    # rename file & return new line
    # file is prefixed with './' to ensure that something like /images/etc.png would not use the root dir
    FileUtils.mv(@path + ('./' + result.to_path.to_s), @path + ('./' + new_date.to_path.to_s))
    return line.sub(result.to_s, new_date.to_s)
  end

end
