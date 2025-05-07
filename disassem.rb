=begin
    Name: Yuesong Huang, Wentao Jiang
    Email: yhu116@u.rochester.edu, wjiang20@u.rochester.edu
=end

require 'erb'

def source_to_html(str)
  if str == nil then return "" end

  str_html = str.gsub(/&/, "&amp;")
  str_html = str_html.gsub(/</, "&lt;")
  str_html = str_html.gsub(/>/, "&gt;")

  return str_html
end

def assembly_to_html(str)
  str_html = source_to_html(str)

  return str_html.gsub(/(?<=\S)\s(?=\S)/, "&nbsp;")
end

def indent_to_html(line_num, max_line_num)
  return "&nbsp;" * (max_line_num.to_s.length - line_num.to_s.length)
end

def pair(is_header, line_nums, address, assembly_instruction)
  # puts "P1 #{line_nums} => #{address}, #{assembly_instruction}"
  if line_nums == []
    if $last_line_num != nil then line_nums << $last_line_num end
  else
    $last_line_num = line_nums.last
  end

  if is_header
    # puts "P2 #{line_nums} => #{address}, #{assembly_instruction}" # [DEBUG]
    $header_count += 1
    @header_table[$current_key][$header_count] = [address, assembly_instruction]
    @header_source[$header_count] += line_nums
    line_nums.each { |line_num| @source_header[line_num] << $header_count }
  else
    # puts "P3 #{line_nums} => #{address}, #{assembly_instruction}" # [DEBUG]
    $assembly_count += 1
    @assembly_table[$current_key][$assembly_count] = [address, assembly_instruction]
    @assembly_source[$assembly_count] += line_nums
    line_nums.each { |line_num| @source_assembly[line_num] << $assembly_count }
  end
end

def parse_dwarf(dwarf)
  llvm_table = {}
  current_key = nil
  is_source = false
  last_line_num = nil

  regex1 = /file_names\[\s*1\]:/
  regex2 = /name:\s*"(([^"]+)\.h)"/
  regex3 = /name:\s*"(([^"]+)\.c)"/
  regex4 = /(0x0*([0-9a-fA-F]+))\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\w*)/

  # Split the llvm-dwarfdump content into lines and iterate over them
  dwarf.each_line do |line|
    # Check for a line indicating a source file and line number mapping
    if regex1.match(line)
      is_source = true
    elsif is_source && regex2.match(line)
      is_source = false
    elsif is_source && (pattern = regex3.match(line))
      current_key = [pattern[2], pattern[1]]
      llvm_table[current_key] = Hash.new { |hash, key| hash[key] = [] }
      is_source = false
    elsif (pattern = regex4.match(line))
      # Extract the information using regular expressions or string parsing
      address = pattern[2]
      line_num = pattern[3].to_i
      file_num = pattern[5].to_i

      if file_num == 1
        llvm_table[current_key][address] << line_num unless llvm_table[current_key][address].include?(line_num)
        last_line_num = line_num
      else
        llvm_table[current_key][address] << last_line_num unless (last_line_num == nil || llvm_table[current_key][address].include?(last_line_num))
      end
    end
  end

  File.write("llvm-dwarfdump.txt", dwarf)
  return llvm_table
end

def parse_assembly(objdump, dwarf_table, source)
  # All header variables are prepared for extract credits
  @header_table = Hash.new { |hash, key| hash[key] = [] }
  @assembly_table = Hash.new { |hash, key| hash[key] = [] }
  @header_source = Hash.new { |hash, key| hash[key] = [] }
  @assembly_source = Hash.new { |hash, key| hash[key] = [] }
  @source_header = Hash.new { |hash, key| hash[key] = [] }
  @source_assembly = Hash.new { |hash, key| hash[key] = [] }
  $header_count = 0
  $assembly_count = 0
  $last_line_num = nil
  $current_key = nil
  is_header = false

  regex1 = /([0-9a-fA-F]+\s)(<(.+)>:)/
  regex2 = /([0-9a-fA-F]+):\t([0-9a-fA-F ]+)(\t(.+))?/

  objdump.each_line do |line|
    # Check for a function identifier line
    if (pattern = regex1.match(line))
      $current_key = pattern[1] + assembly_to_html(pattern[2])
      if source =~ /#{Regexp.escape(pattern[3])}\s*\([^)]*\)/
        is_header = false
        @assembly_table[$current_key] = {}
      else
        is_header = true
        @header_table[$current_key] = {}
      end
    elsif (pattern = regex2.match(line))
      # Extract the information using regular expressions or string parsing
      address = pattern[1]
      assembly = pattern[2]
      instruction = assembly_to_html(pattern[3])
      pair(is_header, dwarf_table[address], address, assembly + instruction)
    end
  end
end

def parse_source(filename)
  # Check if the file exists
  unless File.exist?(filename)
    puts "error: #{filename}: No such file or directory"
    return false, nil
  end

  source = File.read(filename)
  @source_table = {}

  # Split the source code into lines and iterate over them
  source.split("\n").each_with_index do |stmt, line_num|
    # Store the mapping in the hash
    @source_table[line_num + 1] = source_to_html(stmt)
    # puts "S #{line_num + 1} => #{@source_table[line_num + 1]}" # [DEBUG]
  end

  return true, source
end

def to_html(h1_name)
  @h1_name = h1_name
  disassem_template = ERB.new(File.read("disassem.erb"))
  disassem_html = disassem_template.result(binding)
  File.write("#{h1_name}_disassem.html", disassem_html)
end

# Check if an argument is provided
if ARGV.length != 1
  puts "error: ruby disassem.rb [name]: Missing [name]"
  exit 1
end

name = ARGV[0]
# compile source file by name [DEBUG]
# system("gcc -g3 -O1 -o #{name} #{name}.c") # [DEBUG]
# system("gcc -g3 -O3 -o #{name} #{name}.c") # [DEBUG]
# system("gcc -g3 -o #{name} #{name}.c") # [DEBUG]

# dwarf = File.read("llvm-dwarfdump.txt") # [DEBUG]
dwarf = %x{ llvm-dwarfdump --debug-line #{name} }

# objdump = File.read("objdump.txt") # [DEBUG]
objdump = `objdump -d #{name}`
File.write("objdump.txt", objdump)

llvm_table = parse_dwarf(dwarf)

llvm_table.each do |names, dwarf_table|
  is_found, source = parse_source(names[1])
  if is_found
    parse_assembly(objdump, dwarf_table, source)
    to_html(names[0])
  end
end
