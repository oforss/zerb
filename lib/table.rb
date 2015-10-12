require "lib/stats_helper.rb"
require 'lib/runeword_list.rb'

class Table < FXTable
  include StatsHelper
  
  def initialize(p, opts)
    @table = FXTable.new(p, :opts => opts)
    @table.setTableSize(RunewordList::NAME.length, 3)
    set_runeword_table((0..RunewordList::NAME.length-1).to_a)
    @table.connect(SEL_SELECTED) do |data, sel, ptr|
      @table.selectRow(ptr.row)
      $layout.stats_field.text = generate_text(@table.getRowText(ptr.row))
    end

    @table.connect(SEL_CHANGED) do |data, sel, ptr|
      @table.selectRow(ptr.row)
      $layout.stats_field.text = generate_text(@table.getRowText(ptr.row))
    end
  end

  def set_runeword_table(list)
    @table.setTableSize(list.length, 4)

    @table.setColumnText(0, "Item type")
    @table.setColumnWidth(0, 100)
    @table.setColumnText(1, "Level")
    @table.setColumnWidth(1, 35)
    @table.setColumnText(2, "Runes")
    @table.setColumnWidth(2, 147)
    @table.setColumnText(3, "Sockets")
    @table.setColumnWidth(3, 45)
    @table.setRowHeaderWidth(120)
    row = 0
    for i in list
      @table.setRowText(row, RunewordList::NAME[i])
      @table.setItemText(row, 0, RunewordList::ITEM[i].join(" "))
      @table.setItemText(row, 1, RunewordList::LEVEL[i])
      @table.setItemText(row, 2, RunewordList::RUNES[i].join("-"))
      @table.setItemText(row, 3, RunewordList::SOCKETS[i])
      @table.setItemJustify(row, 0, FXTableItem::LEFT)
      @table.setItemJustify(row, 1, FXTableItem::CENTER_X)
      @table.setItemJustify(row, 2, FXTableItem::CENTER_X)
      @table.setItemJustify(row, 3, FXTableItem::TOP)
      row += 1
    end
  end
end