# GUI utilities

require 'gtk2'

def black_box(width, height)
  pixmap = Gdk::Pixmap.new(nil, width, height, 24)
  gc = Gdk::GC.new pixmap
  gc.background = Gdk::Color.new(0, 0, 0)
  return pixmap
end
