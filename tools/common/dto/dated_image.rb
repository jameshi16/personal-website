# A DTO for DatedImages
class DatedImage
  attr_accessor(:path, :date, :sequence, :format)

  def initialize(path: "", date: "", sequence: "", format: "")
    @path = path
    @date = date
    @sequence = sequence
    @format = format
  end

  def to_s
    self.to_str
  end

  def to_str
    return "\"#{@path}#{@date}_#{@sequence}.#{@format}\""
  end

  def to_path
    return Pathname.new "#{@path}#{@date}_#{@sequence}.#{@format}"
  end

  def == other
    return to_str == other.to_str
  end

end
