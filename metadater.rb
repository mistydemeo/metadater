require 'rubygems' # When running under 1.8. Who knows?

require 'mediainfo'
require 'mini_exiftool'
require 'spreadsheet'

# Internal functions and classes

require './lib/mediainfo.rb'
require './lib/exif.rb'
require './lib/client.rb'

# These are the filetypes we consider to be videos
# All others are not videos and we care nothing for them
# Note that we will also scan files with no extensions.
filetypes = [ 'mov', 'avi', 'mp4', 'mts' ]

# Get base directory to scan
# This directory and all its subdirectories will be scanned
scandir = ARGV[0]

case ARGV[0]
  when nil
    puts "usage: metadater <directory>"
    puts "metadater will scan the specified directory and produce a YAML and XLS output at the end of the process."
end
