module RunewordList
  NAME = []
  ITEM = []
  LEVEL = []
  RUNES = []
  SOCKETS = []
  File.open("lib/runewords.ze", "r").each_line do |line|
    a = line.split("\t")
    NAME << a[0]
    ITEM << a[1].to_s.split.collect{|x| x.downcase.to_sym}
    LEVEL << a[2]
    RUNES << a[3].to_s.chomp.split("-")
    SOCKETS << a[4]
  end
end