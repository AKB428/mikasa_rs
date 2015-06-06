require 'pathname'
require 'fileutils'
require 'faraday'
require 'date'
require 'uri'

module DownloadMedia
  IMAGE_FOLDER_NAME = "./image"

#指定された画像をダウンロードして格納したファイルパス文字列を返す
#格納するディレクトリは ./image/YYYY/MM_DD/hogehoge.jpg
    def download_image(url, unique_directory_name = nil)
    today = Date.today
    sub_directory_name = today.year.to_s
    sub_sub_directory_name = today.month.to_s + "_" + today.day.to_s

    target_path = nil

    if unique_directory_name.nil?
     target_path = Pathname.new(IMAGE_FOLDER_NAME).join(sub_directory_name).join(sub_sub_directory_name)
    else
     target_path = Pathname.new(unique_directory_name).join(sub_directory_name).join(sub_sub_directory_name)
    end
    #格納するディレクトリがなかったら作成する
    FileUtils.mkdir_p(target_path) unless File.exist?(target_path)

    file_name = File.basename(url)
    download_file_path = Pathname.new(target_path).join(file_name)

    #指定されたファイルをダウンロードする
    http_conn = Faraday.new do |builder|
      builder.adapter Faraday.default_adapter
    end
    response = http_conn.get url
    File.open(download_file_path, 'wb') { |fp| fp.write(response.body) }

    download_file_path.to_s
  end
end