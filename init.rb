#!/usr/bin/env ruby

require 'fileutils'

folder_path = Dir.pwd

print 'pod name > '
pod_name = gets.chop

author_name = 'Hyper Interaktiv AS'
author_email = 'ios@hyper.no'
username = 'hyperoslo'

file_names = Dir["#{folder_path}/**/*.*"]
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
    new_contents = new_contents.gsub(/<AUTHOR_NAME>/, author_name)
    new_contents = new_contents.gsub(/<AUTHOR_EMAIL>/, author_email)
    new_contents = new_contents.gsub(/<USERNAME>/, username)

    File.open(file_name, "w") {|file| file.puts new_contents }
  end
end

File.rename("#{folder_path}/PODNAME.podspec", "#{folder_path}/#{pod_name}.podspec")

git_directory = "#{folder_path}/.git"
FileUtils.rm_rf git_directory
FileUtils.rm('init.rb')

system("git init && git add . && git commit -am 'Initial commit'")
system("git remote add origin https://github.com/#{username}/#{pod_name}.git")
