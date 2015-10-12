require 'lib/runeword_list.rb'

class Filter
  attr_reader :filtered_words

  def sort_by_socket
    arr = Array.new(5, Array.new)
    for i in @filtered_words
      arr[RunewordList::SOCKETS[i].to_i - 2] += [i]
    end
    return arr.flatten
  end

  def type(type)
    out = []
    $layout.exclusive_check.checked? ? syms = [TYPES[type.to_s][0]]:
                                       syms =  TYPES[type.to_s]
    if syms == [:all]
      return @filtered_words
    end
    a = []
    for k in @filtered_words
      a << RunewordList::ITEM[k]
    end
    for s in syms
      for i in 0..@filtered_words.length-1
        if a[i].index(s)
          out << @filtered_words[i]
        end
      end
    end
    return out
  end

  def level(low, high)
    out = []
    for i in @filtered_words
      out << i if (RunewordList::LEVEL[i].to_i >= low) and (RunewordList::LEVEL[i].to_i <= high)
    end
    return out
  end

  def socket(sockets)
    out = []
    for i in @filtered_words
      for s in sockets
        if RunewordList::SOCKETS[i].to_i == s
          out << i
          break
        end
      end
    end
    return out
  end

  def name(str)
    out = []
    if str == ""
      return @filtered_words
    end
    for i in @filtered_words
      if /#{str.downcase}/ =~ RunewordList::NAME[i].downcase
        out << i
      end
    end
    return out
  end

  def apply_filters
    @filtered_words = (0..RunewordList::NAME.length-1).to_a
    @filtered_words = level($layout.level_low.value.to_i,$layout.level_high.value.to_i)
    @filtered_words = socket($layout.sock_arr)
    @filtered_words = type($layout.type)
    @filtered_words = name($layout.textfield.text).sort
    @filtered_words = sort_by_socket if $layout.socket_sort.checked?
  end
end