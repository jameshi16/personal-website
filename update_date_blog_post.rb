#!/usr/bin/ruby
# update_date_blog_post.rb - Updates the dates used in the Blog Posts
# Usage ./update_date_blog_posts <path to blog post>

require 'date'
require 'tempfile'
require 'fileutils'

def gen_date_line
	DateTime.now.strftime("%Y-%m-%d %H:00 %:z")
end

def gen_date_filename filename
	date = DateTime.now.strftime("%Y-%m-%d")
	return "#{date}-#{filename}"
end

def is_date_line? line_str
	/date: [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2} \+[0-9]{2}:[0-9]{2}/.match? line_str
end

def get_filename_without_date filename	
	/[0-9]{4}-[0-9]{2}-[0-9]{2}-([\s\S]+)/.match(filename)[1]
end

def process_line (line, line_num)
	if is_date_line? line
		puts "date line found in line #{line_num}"
		return "date: #{gen_date_line}\n"
	end
	return line
end

def modify_file filename
	Tempfile.create("update_date_blog_posts") do |out_file|
		IO.foreach(filename).with_index do |line, line_num|
			out_file.write process_line(line, line_num)
		end

		out_file.seek(0, :SET)
		IO.copy_stream(out_file, filename)
	end
end

def update_filename filename
		dir = File.dirname filename
		src = filename
		dest = "#{dir}/#{gen_date_filename get_filename_without_date filename}"
		if src == dest
			puts("source and destination file name is the same. skipping...")	
			return 0
		end

		puts("renamed file to #{dest}")
		FileUtils.mv(src, dest) 
end

def help
	puts "Usage"
	puts "#{$0} <path to blog post>"
	puts "Changes the date of the blog post"
end

if __FILE__ == $0
	if $*.empty?
		puts("need a path to a file")
		help
		exit
	end

	if $*.length > 1
		puts("too many arguments")
		help
		exit
	end

	if !File.exist? $*[0]
		puts("file doesn't exist")
		exit
	end

	modify_file $*[0]
	update_filename $*[0]
end
