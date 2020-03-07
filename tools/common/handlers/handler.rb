module Handler

  attr_accessor :processors
  
  def handle
   raise "not implemented"
  end 

  def do_process(line_num, line)
    @processors.each { |processor|
      line = processor.process(line_num, line)
    }
    return line
  end

  def append_processor arg
    raise "not implemented"
  end

end
