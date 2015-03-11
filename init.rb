require 'fileutils'

print 'pod name > '
cocoapod = gets.chop
file_names = Dir["#{Dir.pwd}/**/*.*"]
ignored_file_types = ['.xccheckout',
                      '.xcodeproj',
                      '.xcworkspace',
                      '.xcuserdatad',
                      '.xcuserstate']

file_names.each do |file_name|
    if !ignored_file_types.include?(File.extname(file_name))
        text = File.read(file_name)
        new_contents = text.gsub(/Foobar/, cocoapod)
        File.open(file_name, "w") {|file| file.puts new_contents }
    end
end

git_directory = "#{Dir.pwd}/.git"
FileUtils.rm_rf git_directory

system("git init && git add . && git commit -am 'Initial commit'")
