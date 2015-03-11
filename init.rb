#!/usr/bin/env ruby

require 'fileutils'

folder_path = Dir.pwd

print 'pod name > '
pod_name = gets.chop

file_names = Dir["#{Dir.pwd}/**/*.*"]
ignored_file_types = ['.xccheckout',
                      '.xcodeproj',
                      '.xcworkspace',
                      '.xcuserdatad',
                      '.xcuserstate',
                      '.rb']

file_names.each do |file_name|
  if !ignored_file_types.include?(File.extname(file_name))
    text = File.read(file_name)
    new_contents = text.gsub(/<PODNAME>/, pod_name)
    File.open(file_name, "w") {|file| file.puts new_contents }
  end
end

File.rename("#{folder_path}/PODNAME.podspec", "#{folder_path}/#{pod_name}.podspec")

git_directory = "#{folder_path}/.git"
FileUtils.rm_rf git_directory

system("git init && git add . && git commit -am 'Initial commit'")
system("git remote add origin https://github.com/hyperoslo/#{pod_name}.git")
FileUtils.rm('init.rb')
