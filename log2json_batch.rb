require 'json'
require 'pathname'

File.open './config/application.json' do |file|
  conf = JSON.load(file.read)
  @http_conf = conf["HTTP_Server"]
  @log_path = conf["log_path"]
  @kafka_conf = conf["Kafka"]
end

@out_path = @http_conf['document_path']

puts @log_path
puts @out_path

#log 配下に convertedフォルダを作る
converted_path = File.join(@log_path, 'converted')
Dir.mkdir(converted_path) unless File.exists?(converted_path)



#変換したファイルはHTML配下に配置
#min5なら/5/log min60なら/60/log ない場合はSKIP
def move_folder_name(target_min)
  target_path = File.join(@out_path, target_min.to_s, 'log')
  Dir.mkdir(File.join(@out_path, target_min.to_s)) unless File.exists?( File.join(@out_path, target_min.to_s))
  Dir.mkdir(target_path) unless File.exists?(target_path)
  target_path
end

#ファイル名からtarget_minを割り出す
def target_min_from_file(file_name)
  /every(\d+)min.*/ =~ file_name
  $1
end


def today_file?(filename)
    now = Time.now.strftime("%Y%m%d")
    filename.include?(now)
end

#ファイルを変換する
# /log/every60min20150615.log -> /html/60/log/every60min20150615.json
Dir::entries(@log_path).each do |filename|
  #puts filename
  next if (filename == '.' || filename == '..' || filename == 'converted')
  target_min =  target_min_from_file(filename)

  move_folder = move_folder_name(target_min)

  move_file_path = File.join(move_folder,Pathname(filename).sub_ext('.json').to_s )

  puts move_file_path

  original_log_file_path = File.join(@log_path, filename)

  system("ruby bin/log2d3json_not60limit.rb #{original_log_file_path} > #{move_file_path}")

  #convertedに移動する(今日のファイル以外)
  if (today_file?(original_log_file_path) == false)
    system("mv #{original_log_file_path} #{converted_path}")
  end
end



