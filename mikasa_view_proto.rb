require 'json'

topic = ARGV[0]
target_min = ARGV[1]

#テスト用
input_data = ARGV[2]


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

def save_data_json(target_min, data_json)
  parent_path = File.join(@http_conf['document_path'], target_min)
  Dir.mkdir(parent_path) unless File.exists?(parent_path)

  #ファイルは強制上書き
  data_file_path = File.join(parent_path,"data.json")
  view_file_path = File.join(parent_path,"view.json")

  #p data_file_path
  #p view_file_path

  open( data_file_path , 'w' ){|f| f.write(data_json)}

  view = {}
  view['date'] = Time.now.strftime("%Y%m%d %H:%m")
  view_data = JSON.dump(view)

  open( view_file_path , 'w' ){|f| f.write(view_data)}

end

def save_log(target_min, data_string)
  #その日のファイルがなかったら作成
  # every3min_20150606.log
  filename = 'every' + target_min + "min" + Time.now.strftime("%Y%m%d%h%m") + ".log"
  file_path = File.join(@log_path, filename)
  #そのファイルにアペンド
  open( file_path , 'a' ){|f| f.puts(data_string)}
end


File.open './config/application.json' do |file|
  conf = JSON.load(file.read)
  @http_conf = conf["HTTP_Server"]
  @log_path = conf["log_path"]
end

out_path = File.join(@http_conf['document_path'], target_min)


Dir.mkdir(out_path) unless File.exists?(out_path)

save_log(target_min, input_data)
data_json = generate_json_data(input_data)

#puts data_json

save_data_json(target_min, data_json)