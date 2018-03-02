#!/usr/bin/env ruby

require "./ruby_lab"

file = "a_tracks.txt"
count = 0
IO.foreach(file) do |line|
	song = cleanup_title(line)
	if song =~ //
		put $&
	end

	puts song
end
