require 'json'

filename = ARGV[0]

def build_children(title, value)
  children = {}
  children['name'] = title
  children['children'] = []
  children['children'][0] = {'name' =>  title, 'size' => value}
  children
end

def build_data(csv_data_map)
  data = {}
  data['name'] = 'flare'
  data['children'] = csv_data_map.map{|k, v| build_children(k,v)}
  JSON.dump(data)
end


def generate_json_data(data_string)

  data_map = {}

  ds = data_string.gsub(/,$/,'')

  ds.split(',').each do |data|
    a = data.split(':')
    data_map[a[0]] = a[1]
  end

  build_data(data_map)
end

lines = 0
data = []
open(filename) {|file|
  while l = file.gets
    lines += 1
    data.push(l)
  end
}

start_line = lines - 60 > 1 ? lines - 60 : 1
end_line = lines

output = '['
(start_line..end_line).each do |i|
  output+= generate_json_data(data[i - 1]) + ','
end

output.gsub!(/,$/,'')
output += ']'
puts output

