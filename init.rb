#!/usr/bin/env ruby

require 'fileutils'

def prompt(message, default)
  print "#{message} (or press enter to use: #{default}) > "
  input = gets.chomp
  input = nil if input.strip.empty?
  input
end

def prompt(message)
  print "#{message} > "
  input = gets.chomp
  input = nil if input.strip.empty?
  input
end

folder_path = __dir__

default_pod_name = 'MyPod'
default_author_name = 'Elvis Nuñez'
default_author_email = 'elvisnunez@me.com'
default_username = '3lvis'

pod_name = ARGV.shift || prompt('pod name', default_pod_name) || default_pod_name
has_dependencies = prompt('has dependencies? (y/n)') || 'y'
author_name = prompt('author', default_author_name) || default_author_name
author_email = prompt('e-mail', default_author_email) || default_author_email
username = prompt('username', default_username) || default_username

file_names = Dir["#{folder_path}/**/*.*"]
file_names.push("Podfile")
ignored_file_types = ['.xccheckout',
                      '.xcodeproj',
                      '.xcworkspace',
                      '.xcuserdatad',
                      '.xcuserstate',
                      '.lproj',
                      '.xcassets',
                      '.appiconset',
                      '.xctemplate',
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
if has_dependencies == 'y'
  system("pod install")
else
  FileUtils.rm('Podfile')
end
system("git init && git add . && git commit -am 'Initial commit'")
system("git remote add origin git@github.com:#{username}/#{pod_name}.git")
