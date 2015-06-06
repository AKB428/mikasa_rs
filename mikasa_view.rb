require 'json'
require 'poseidon'

topic = ARGV[0]
@target_min = ARGV[1]


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

def save_data_json(date, target_min, data_json)
  parent_path = File.join(@http_conf['document_path'], target_min)
  Dir.mkdir(parent_path) unless File.exists?(parent_path)

  #ファイルは強制上書き
  data_file_path = File.join(parent_path,"data.json")
  view_file_path = File.join(parent_path,"view.json")

  #p data_file_path
  #p view_file_path

  open( data_file_path , 'w' ){|f| f.write(data_json)}

  view = {}
  view['date'] = date.strftime("%Y年%m月%d日 %H時%M分")
  view['date'] = target_min
      view_data = JSON.dump(view)

  open( view_file_path , 'w' ){|f| f.write(view_data)}

end

def save_log(date, target_min, data_string)
  #その日のファイルがなかったら作成
  # every3min_20150606.log
  filename = 'every' + target_min + "min" + Time.now.strftime("%Y%m%d") + ".log"
  file_path = File.join(@log_path, filename)
  #そのファイルにアペンド
  open( file_path , 'a' ){|f| f.puts(  date.strftime("%Y%m%d%H%M") + "," + data_string)}
end


File.open './config/application.json' do |file|
  conf = JSON.load(file.read)
  @http_conf = conf["HTTP_Server"]
  @log_path = conf["log_path"]
  @kafka_conf = conf["Kafka"]
end
out_path = File.join(@http_conf['document_path'], @target_min)
Dir.mkdir(out_path) unless File.exists?(out_path)



# http://kafka.apache.org/07/configuration.html
# https://spark.apache.org/docs/1.3.0/streaming-kafka-integration.html
# OSX: home brew
#      cat /usr/local/etc/kafka/consumer.properties
#      group.id=test-consumer-group

consumer = Poseidon::PartitionConsumer.new(@kafka_conf['group_id'], @kafka_conf['hostname'], @kafka_conf['port'],
                                           topic, 0, :latest_offset)

loop do
  messages = consumer.fetch
  messages.each do |m|

    date = DateTime.now
    puts date.to_s

    puts m.value
    input_data = m.value

    begin
     save_log(date, @target_min, input_data)
    rescue => ex
     puts ex.to_s
    end

    begin
      save_data_json(date, @target_min, generate_json_data(input_data.force_encoding('utf-8')))
    rescue => ex
      puts ex.to_s
    end

  end
end


