require 'rubygems' # When running under 1.8. Who knows?

require 'mediainfo'
require 'mini_exiftool'
require 'spreadsheet'

# File-find gem, enables recursively searching a path
# Note that the Rubygems version of file-find is broken as of 0.3.4
# Make sure you install file-find from the Github source
require 'file/find' 

# Internal functions and classes

require File.dirname(__FILE__) + '/lib/mediainfo.rb'
require File.dirname(__FILE__) + '/lib/exif.rb'
require File.dirname(__FILE__) + '/lib/client.rb'

# These are the filetypes we consider to be videos
# All others are not videos and we care nothing for them
# Note that we will also scan files with no extensions.
filetypes = [ 'mov', 'avi', 'mp4', 'mts' ]

case ARGV[0]
  when nil
    puts "usage: metadater <directory>"
    puts "metadater will scan the specified directory and produce a YAML and XLS output at the end of the process."
  when String
    # Get base directory to scan
    # This directory and all its subdirectories will be scanned
    scandir = ARGV[0]
end

