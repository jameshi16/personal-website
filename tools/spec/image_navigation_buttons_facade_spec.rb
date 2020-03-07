require "./common/image_navigation_buttons_facade"

include RSpec

class ImageCaptionFacadeMock
  attr_accessor :previous_called
  attr_accessor :next_called
  attr_accessor :save_called
  attr_accessor :on_load_images # TODO: Test this variable
  
  def initialize
    @previous_called = false
    @next_called = false
    @save_called = false
  end

  def next_available?
    true
  end

  def previous_available?
    true
  end

  def on_previous
    @previous_called = true
  end

  def on_next
    @next_called = true
  end

  def on_save
    @save_called = true
  end
end

class MockButton
  attr_accessor :signal
  attr_accessor :block
  attr_accessor :sensitive # TODO: Might want to test this too

  def initialize
    @signal = ""
  end

  def signal_connect(signal, &block)
    @signal = signal
    @block = block
  end

  def exec_block()
    @block.call
  end
end

describe ImageNavigationButtonsFacade do
  imgcap_facade = ImageCaptionFacadeMock.new
  button_prev = MockButton.new
  button_next = MockButton.new
  button_save = MockButton.new
  button_replace = MockButton.new

  imbf = ImageNavigationButtonsFacade.new(imgcap_facade, button_prev, button_next, button_save, button_replace)
  
  describe :attach_signal_callbacks do
    it "attaches the signals with clicked" do
      expect(button_prev.signal).to eq("")
      expect(button_next.signal).to eq("")
      expect(button_save.signal).to eq("")
      expect(button_replace.signal).to eq("")

      imbf.attach_signal_callbacks

      expect(button_prev.signal).to eq("clicked")
      expect(button_next.signal).to eq("clicked")
      expect(button_save.signal).to eq("clicked")
      expect(button_replace.signal).to eq("clicked")
    end
  end 

  describe :on_previous do
    it "propogates to the underlying image caption facade" do
      button_prev.exec_block 
      expect(imgcap_facade.previous_called).to eq(true)
    end
  end

  describe :on_next do
    it "propogates to the underlying image caption facade" do
      button_next.exec_block
      expect(imgcap_facade.next_called).to eq(true)
    end
  end

  describe :on_save do
    it "propogates to the underlying image caption facade" do
      button_save.exec_block
      expect(imgcap_facade.save_called).to eq(true)
    end
  end

end
