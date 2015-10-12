begin
  require "rubygems"
rescue LoadError
end

require "fox16"
include Fox

require "lib/layout.rb"
require "lib/runeword_list.rb"

module ZErb
  class MainWindow < FXMainWindow
    def initialize(app)
      super(app, "ZERB", :width => 760, :height => 600)

      options_panel = FXVerticalFrame.new(self, :opts => LAYOUT_SIDE_RIGHT|LAYOUT_FILL_Y|PACK_UNIFORM_WIDTH, :width => 300, :vSpacing => 6)
      $layout = Layout.new
      $layout.draw(self, options_panel, app)
      $layout.update(app)
    end

    def create
      super
      show(PLACEMENT_SCREEN)
    end
  end
end

if __FILE__ == $0
  if not defined?(Ocra)
    FXApp.new do |app|
      ZErb::MainWindow.new(app)
      app.create
      app.run
    end
  end
end