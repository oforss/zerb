require 'lib/item_types.rb'
require 'lib/table.rb'
require 'lib/filters.rb'
include ItemTypes

class Layout
  attr_reader :type
  attr_reader :textfield
  attr_reader :stats_field
  attr_reader :exclusive_check
  attr_reader :level_low
  attr_reader :level_high
  attr_reader :socket_sort

  def draw(left, p, app)
    @p = p
    
    draw_name_filter
    draw_level_sliders
    draw_type_filter(app)
    draw_socket_filter
    
    @stats_field = FXText.new(@p, :opts => LAYOUT_FILL|TEXT_READONLY)
    FXVerticalSeparator.new(left, LAYOUT_SIDE_RIGHT|LAYOUT_FILL_Y|SEPARATOR_GROOVE)
    @table = Table.new(left, TABLE_READONLY|TABLE_COL_RENUMBER|TABLE_COL_SIZABLE|TABLE_NO_COLSELECT|LAYOUT_TOP|LAYOUT_LEFT|LAYOUT_FILL)

    @filter = Filter.new
  end

  def update(app)
    @textfield.connect(SEL_LEFTBUTTONPRESS) do |data, sel, ptr|
      @textfield.text = ""
      update_curr(app)
    end
    @textfield.connect(SEL_CHANGED) {update_curr(app)}    

    @level_low.connect(SEL_COMMAND) do
      update_curr(app)
      level_data
    end
    @level_high.connect(SEL_COMMAND) do
      update_curr(app)
      level_data
    end

    @sock_buttons.each do |button|
      button.connect(SEL_COMMAND) {update_curr(app)}
    end
    @socket_sort.connect(SEL_COMMAND) {update_curr(app)}
    @all_button.connect(SEL_COMMAND) do
      @sock_buttons.each {|button| button.setCheck(TRUE)}
      update_curr(app)
    end
    @none_button.connect(SEL_COMMAND) do
      @sock_buttons.each {|button| button.setCheck(FALSE)}
      update_curr(app)
    end

    @type_filter.connect(SEL_COMMAND) do
      @type = @type_filter.getCurrent
      update_curr(app)
    end
    @exclusive_check.connect(SEL_COMMAND) {update_curr(app)}
    
    @reset_button.connect(SEL_COMMAND) do
      reset
      update_curr(app)
    end
  end
  
  def reset
    for i in 2..6
      @sock_buttons[i-2].setCheck(TRUE)
    end
    @textfield.text = ""
    @type = "Show All Items"
    @type_filter.text = @type
    @level_low.value = 1
    @level_high.value = 255
    @exclusive_check.setCheck(FALSE)
    @socket_sort.setCheck(FALSE)
  end

  def update_curr(app)
    @filter.apply_filters
    @table.set_runeword_table(@filter.filtered_words.uniq)
    app.refresh
  end
 
  def level_data
    @low_slider.range = 0..@level_high.value
    @high_slider.range = @level_low.value..255
  end

  def draw_name_filter
    name_frame = FXHorizontalFrame.new(@p)
    FXLabel.new(name_frame, "Name: ")

    @textfield = FXTextField.new(name_frame, 15, :opts => TEXTFIELD_NORMAL|LAYOUT_FILL_X)
    @reset_button = FXButton.new(name_frame, "Reset Filters")
  end

  def draw_type_filter(app)
    type_box = FXGroupBox.new(@p, "Item type:", :opts => FRAME_GROOVE|LAYOUT_FILL_X)
    item_type = FXPopup.new(@p, :opts => ICON_AFTER_TEXT|LAYOUT_FILL)
    @type = "Show All Items"
    t = FXOption.new(item_type, "Show All Items", :opts => JUSTIFY_HZ_APART|ICON_AFTER_TEXT)
    t.connect(SEL_COMMAND) do |data, sel, ptr|
      @type = data.to_s
      @type_filter.text = @type
      update_curr(app)
    end
    MASTER_TYPES.each_pair{|name, arr|
      sub = FXPopup.new(@p)
      arr.each{|k2|
        t = FXOption.new(sub, k2, :opts => JUSTIFY_HZ_APART|ICON_AFTER_TEXT)
        t.connect(SEL_COMMAND) do |data, sel, ptr|
          @type = data.to_s
          @type_filter.text = @type
          update_curr(app)
        end
       }
      FXMenuCascade.new(item_type, name, nil, sub)
    }
    @type_filter = FXMenuButton.new(type_box, @type, nil, item_type, :opts => ICON_AFTER_TEXT|LAYOUT_FILL_X|MENUBUTTON_ATTACH_CENTER)
    pane = FXMatrix.new(type_box, 2, :opts => MATRIX_BY_COLUMNS|LAYOUT_FILL_X)
    @exclusive_check = FXCheckButton.new(pane, "&Exclusive")
  end

  def draw_level_sliders
    level_group = FXGroupBox.new(@p, "Level:", :opts => FRAME_GROOVE|LAYOUT_FILL_X)
    @level_low  = FXDataTarget.new(1)
    @level_high = FXDataTarget.new(255)

    low_frame = FXHorizontalFrame.new(level_group)
    high_frame = FXHorizontalFrame.new(level_group)
    FXLabel.new(low_frame, "Low ")
    FXLabel.new(high_frame, "High")

    @low_slider = FXSlider.new(low_frame, @level_low,
                 FXDataTarget::ID_VALUE, LAYOUT_FIX_WIDTH, :width => 140)
    @high_slider = FXSlider.new(high_frame, @level_high,
                 FXDataTarget::ID_VALUE,LAYOUT_FIX_WIDTH, :width => 140)
    @low_slider.range = @high_slider.range = 0..255
    FXTextField.new(low_frame, 3, @level_low, FXDataTarget::ID_VALUE,
                    :opts => TEXTFIELD_INTEGER|TEXTFIELD_LIMITED|FRAME_NONE)
    FXTextField.new(high_frame, 3, @level_high, FXDataTarget::ID_VALUE,
                    :opts => TEXTFIELD_INTEGER|TEXTFIELD_LIMITED|FRAME_NONE)
  end

  def draw_socket_filter
    socket_box = FXGroupBox.new(@p, "Sockets:", :opts => FRAME_GROOVE|LAYOUT_FILL_X)
    matrix = FXMatrix.new(socket_box, 5, :opts => MATRIX_BY_COLUMNS)
    btn_matrix = FXMatrix.new(socket_box, 2, :opts => MATRIX_BY_COLUMNS)
    @sock_buttons = []
    for i in 2..6
      @sock_buttons << FXCheckButton.new(matrix, "&#{i}")
      @sock_buttons[i-2].setCheck(TRUE)
    end

    @all_button  = FXButton.new(btn_matrix, "Select &all")
    @none_button = FXButton.new(btn_matrix, "Select &none")

    @socket_sort = FXCheckButton.new(socket_box, "&Sort by socket before level")
  end

  def sock_arr
    i = 2
    out = []
    @sock_buttons.each do |x|
      out << i if x.checked?
      i += 1
    end
    return out
  end
end