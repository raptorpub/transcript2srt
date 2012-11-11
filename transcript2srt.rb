require 'open-uri'
require 'nokogiri'
require 'zip/zip'
require 'zip/zipfilesystem'

doc = Nokogiri::HTML(open('http://www.lynda.com/Photoshop-tutorials/Photoshop-for-Web-Design/105368-2/transcript'))
#doc = Nokogiri::HTML(open('http://www.lynda.com/Bootstrap-tutorials/Up-Running-Bootstrap/110885-2/transcript'))

delimiter = " "

title = doc.css('title').text.split('|')[0]
title.strip!
Dir.mkdir(title) if !File.exist?(title)

doc.css('.tChap').each_with_index do |t, fd|
  tmp = t.css('.chTitle').text
  folder_tmp = tmp
  if !tmp.index('.').nil?
    num, folder_tmp = tmp.split('.')
    folder_tmp.strip!
  end

  if fd < 10
    folder = "0" + fd.to_s + delimiter + folder_tmp
  else
    folder = fd.to_s + delimiter + folder_tmp
  end

  t.css('.showToggleDeltails').each_with_index do |std, fi|

    filename = ""
    if fi < 9
      filename = "0" + (fi+1).to_s + " " + std.css('.toggle').text
    else
      filename = (fi+1).to_s + " " + std.css('.toggle').text
    end

    if !filename.index('?').nil?
      filename = filename.split('?')[0]
    end

    temp = []
    std.css('.tC').each do |t|
      temp << t.text
    end

    i = 0
    time_stamp = []
    while i < temp.size - 1 do
      time_stamp[i] = "00:" + temp[i] + ",000-->00:" + temp[i + 1] + ",000"
      i = i + 1
    end

    transcript = []
    std.css('.c').each do |ts|
      transcript << ts.text
    end
    path = "./"+ title + "/" + folder
    Dir.mkdir(path) if !File.exist?(path)
    file = File.new(path + "/" + filename + ".srt", "w")
    if file
      time_stamp.each_with_index do |ts, index|
        file.puts ""
        file.puts index + 1
        file.puts ts
        file.puts transcript[index]
      end
    else
      puts "Unable to create file!"
    end
    file.close

  end
end

def compress(path)
  path.sub!(%r[/$], '')

  archive = path + '.zip'

  FileUtils.rm archive, :force => true

  Zip::ZipFile.open(archive, 'w') do |zipfile|
    Dir["#{path}/**/**"].reject { |f| f==archive }.each do |file|
      zipfile.add(file.sub(path+'/', ''), file)
    end
  end

  FileUtils.rm_rf path

end

compress(title)
