require "lib/attributes"
require "lib/runeword_stats"
require "lib/runeword_list"
require "lib/item_types"
include Attributes
include RunewordStats

module StatsHelper
  def get_stats(rw)
    if rw then
      return "BROKEN" if rw[:broken]
      out = ""
      rw[:stats].delete(:d)
      
      rw[:stats].sort.each do |a|
        str = String.new(STATS[a[0].to_i]) #Remember to do this, or STATS will change permanently when you change str
        count = 1
        str.scan(/\[.+?\]/).each do |match|
          if a[1][0][match[1..-2].to_sym] then
            str[match] = a[1][0][match[1..-2].to_sym]
          else
            str[match] = a[1][count]
            count += 1
          end
        end
        out += str.capitalize + "\n"
      end
      return out
    end
  end
  
  def generate_text(name)
    out = ""
    index = RunewordList::NAME.index(name)
    name_sym = replace_with_underscores(name.downcase).to_sym
    rw = RUNEWORD_STATS[name_sym]
    stats = get_stats(rw)
	return stats if stats == "BROKEN"
    
    out += name + " -- " + RunewordList::RUNES[index].join("-") + "\n"
    out += RunewordList::ITEM[index].collect {|x| get_type(x)}.join(", ") + "\n"
    out += "Level: " + RunewordList::LEVEL[index] + "\n"
    if rw then
      out += "Created: " + rw[:created].to_s + "\n\n"
      out += "Attributes (#{rw[:created_in].downcase})\n"
      out += stats
    else
      out += "Created: 0\n"
      out += "\nStat data not present"
    end
    
    return out
  end
  
  def get_type(key)
    ItemTypes::TYPES.each_pair do |k,v|
      if v[0] == key.to_sym then
        return k
      end
    end
    return key
  end   
  
  def replace_with_underscores(str)
    out = ""
    str.each_char do |c|
      /[a-z0-9]/ =~ c ? out << c : out << "_"
    end
    return out
  end
end