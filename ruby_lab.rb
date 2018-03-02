#!/usr/bin/ruby

###############################################################
#
# CSCI 305 - Ruby Programming Lab
#
# Kirby Overman
# kirby.overman@gmail.com
#
###############################################################

$bigrams = Hash.new(-1) # The Bigram data structure - This is essentially an associative array of associative arrays of integers
$name = "Kirby Overman"

$most_common = Hash.new(-1) # Here I store the most common words (word => most common next word)

# I decided to keep the stop words as a list for quick iteration and checking for array inclusion before populating the bigrams
$stop_words = ['a', 'an', 'and', 'by', 'for', 'from', 'in', 'of', 'on', 'or', 'out', 'the', 'to', 'with']

# Strip away track string down to track title - remove titles with non english characters
# Params:
# + track :: unsanitized string representing track, with id, title, artists, etc.
def cleanup_title(track)
	if track =~ /<SEP>.*<SEP>.*<SEP>(.*?)(feat.|[\(\[{\\\/\-\_\:\"\`\+\=\*]|$)/ # First capture group is track title without extra bits (e.g. feat. or '(' )
		title = $1.gsub(/(\.|\?|\!|\;|\&|\@|\||\¡|\¿)/, '') # replace punctuation with the empty string - assign to @var title
		if title =~ /[^a-zA-Z0-9\w\s\']/ # If track title matches non english characters, return nil
			nil
		else
			title.downcase # return lower case title
		end
	end
end

# Fetch the most common word following title (string)
# Params:
# + title :: string, return value with key = title
def mcw(title)
	$most_common[title]	
end

# Get the most common word following each word in the bigram and insert into $most_common for faster look ups
def get_most_common_words
	$bigrams.each do |key, word| # iterate over bigram hash
		max_word = word.max_by{|k, count| count} # get max element of bigram word hash
		$most_common[key] = max_word[0]
	end
end

# Generate new song titles based on most common words
# Params:
# title :: string, generate song starting with title
def create_title(title)
	song = [title] # init song as array of title
	while $most_common[title] != -1 # while title exists
		title = $most_common[title] # update title to be next word
		break if song.include?(title) # if next word has already appeared, break from loop
		song.push(title) # else add next word to new song title
	end
	song.join(" ") # convert song array to string separated by single white space
end

# function to process each line of a file and extract the song titles
def process_file(file_name)
	puts "Processing File.... "

	begin
		count = 0
		IO.foreach(file_name, encoding: "utf-8") do |line|
			title = cleanup_title line
			
			next if title.nil? # if title is empty, skip
			
			words = title.split(" ") # convert string with spaces to array of words
			$stop_words.each do |w|
				words.delete(w) # if a word is on the stop word list, remove
			end
			(words.length - 1).times do |word_index|
				if $bigrams[words[word_index]] == -1 # if word does not yet exist as a key in the bigram
					$bigrams[words[word_index]]	= Hash.new(-1) # add word as a hash object - default -1
				end
				if $bigrams[words[word_index]][words[word_index + 1]] == -1 # if next word does not yet exist as a key in the newly created hash
					$bigrams[words[word_index]][words[word_index + 1]] = 1 # add next word, set count to 1
				else
					$bigrams[words[word_index]][words[word_index + 1]] += 1 # else increment number of times we have seen this word ordering
				end
			end
		end

		get_most_common_words # populate $most_common hash object
		puts "Finished. Bigram model built.\n"
	rescue
		puts $! # If error, report error message to console
		STDERR.puts "Could not open file"
		exit 4
	end
end

# Executes the program
def main_loop()
	puts "CSCI 305 Ruby Lab submitted by #{$name}"

	if ARGV.length < 1
		puts "You must specify the file name as the argument."
		exit 4
	end

	# process the file
	process_file(ARGV[0])

	# Get user input
	reader = IO.sysopen "/dev/tty", 'r' # For some reason, the IO was reading in the file lines
	ios = IO.new(reader, 'r') # I created a new IO object for the console (/dev/tty)
	while true # repeat indefinitely
		print "Enter a word [Enter 'q' to quit]: " # prompt
		input = ios.gets.chomp # get song title from console
		break if input == 'q' # if exit command give, break from loop
		puts create_title input # print the made up song title
	end
end


if __FILE__ == $0
	main_loop()
end
