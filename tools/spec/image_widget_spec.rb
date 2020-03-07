require './common/gui_utils'
require './common/image_widget'

include RSpec

describe ImageWidget do

  it "accepts a reference to a file that exists" do
    test_file = "./fixtures/input/gods_memopad.jpg" 
    ImageWidget.new test_file # expect no exception
  end

  it "does not accept a reference to a file that does not exist" do
    test_file = "./fixtures/doesnt_exist.jpg"
    expect{ImageWidget.new test_file}.to raise_error(ArgumentError)
  end

  it "draws a black box when empty" do
    ImageWidget.new "" 
    # expect(iw.pixmap).to eq(black_box(300, 300)) TODO: don't have a way of comparing images atm
  end

  it "draws a larger black box" do
    iw = ImageWidget.new ""
    iw.placeholder_width = 500
    iw.placeholder_height = 500

    # expect(iw.pixmap).to eq(black_box(500, 500))
  end

end
