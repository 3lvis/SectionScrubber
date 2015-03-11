require 'fileutils'

folder_path = Dir.pwd

print 'pod name > '
pod_name = gets.chop
print 'pod description > '
pod_description = gets.chop

file_names = Dir["#{Dir.pwd}/**/*.*"]
ignored_file_types = ['.xccheckout',
                      '.xcodeproj',
                      '.xcworkspace',
                      '.xcuserdatad',
                      '.xcuserstate']

file_names.each do |file_name|
    if !ignored_file_types.include?(File.extname(file_name))
        text = File.read(file_name)
        new_contents = text.gsub(/<PODNAME>/, pod_name)
        new_contents = text.gsub(/<PODDESCRIPTION>/, pod_description)
        File.open(file_name, "w") {|file| file.puts new_contents }
    end
end

File.rename("#{Dir.pwd}/PODNAME.podspec", "#{Dir.pwd}/#{pod_name}.podspec")

git_directory = "#{Dir.pwd}/.git"
FileUtils.rm_rf git_directory

system("git init && git add . && git commit -am 'Initial commit'")
