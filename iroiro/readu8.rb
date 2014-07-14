# ルービ-Test
# XXX-Test
path=ARGV[0]||$0
f=File.open(path,'r:BOM|UTF-8')
loop do
  break if f.eof?
  x=f.readline
  puts "#{f.lineno}: #{x.chomp.length} |"+x
end
