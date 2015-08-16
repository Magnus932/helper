
# Simple ruby implementation to recursively look for
# a string or file inside a root directory.
require "getoptlong"
require "colorize"

class Finder

	SEARCH_MODE_FILE = 0
	SEARCH_MODE_STRING = 1

	def initialize()
		opts = GetoptLong.new(
			["--file", "-f", GetoptLong::REQUIRED_ARGUMENT],
			["--str", "-s", GetoptLong::REQUIRED_ARGUMENT],
			["--strict", GetoptLong::NO_ARGUMENT],
			["--help", "-h", GetoptLong::NO_ARGUMENT]
		)
		mode = nil
		opts.each do |opt, arg|
			case (opt)
				when "--file" then
					mode = SEARCH_MODE_FILE
					@fname = arg
				when "--str" then
					mode = SEARCH_MODE_STRING
					@string = arg
				when "--strict" then
					@__SEARCH_STRICT = true
				when "--help" then
					help = String.new()
					help.concat("--file, -f:\tSearch for a file\n")
					help.concat("--str, -s:\tSearch for a string\n")
					help.concat("--strict:\tSearch for a file with strict " \
								"comparison\n")
					abort(help)
			end	
		end
		if (mode == nil) then
			abort("No argument given. Use --help\n")
		end
		if (!ARGV[0]) then
			abort("Directory was not passed\n")
		end

		__run_setup(mode, ARGV[0])
	end

	def __run_setup(mode, dir)
		if (!Dir.exists?(dir)) then
			printf("Directory %s do not exist\n", dir)
			exit()
		end
		dir = dir.sub(/\/+$/, "")
		if (mode == SEARCH_MODE_FILE) then
			locate_file(dir)
		elsif (mode == SEARCH_MODE_STRING) then
			locate_string(dir)
		end
	end

	def locate_string(dir)
		begin
			d = Dir.new(dir)
		rescue Exception => e
			puts e.message()
			return
		end
		p = d.path().concat("/")

		d.each do |i|
			if (i == "." || i == "..") then
				next
			end
			if (File.blockdev?(p + i) || File.chardev?(p + i) ||
				File.socket?(p + i)) then
				next
			end
			if (File.file?(p + i)) then
				begin
					File.open(p + i, "r") do |f|
						f.each_line do |line|
							if (line.include?(@string)) then
								b = line.slice(0, line.index(@string))
								e = line.slice(line.index(@string) + @string.length,
										   	   line.length)
								printf("%s %d. %s%s%s", p + i, f.lineno,
														b, @string.red(), e)
							end
						end
					end
				rescue Exception => e
					puts e.message()
				end
				next
			end
			if (File.directory?(p + i)) then
				locate_string(p + i)
			end
		end
		d.close()
	end

	def locate_file(dir)
		begin
			d = Dir.new(dir)
		rescue Exception => e
			puts e.message()
			return
		end
		p = d.path().concat("/")

		d.each do |i|
			if (i == "." || i == "..") then
				next
			end
			if (@__SEARCH_STRICT) then
				if (i.eql?(@fname)) then
					puts p + i
				end
			else
				if (i.include?(@fname)) then
					puts p + i
				end
			end
			if (File.directory?(p + i)) then
				locate_file(p + i)
			end
		end
		d.close()
	end
end

klass = Finder.new()
