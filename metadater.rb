require 'rubygems'      # When running under 1.8. Who knows?

require 'mediainfo'     # Capture technical metadata from video. Requires MediaInfo
require 'mini_exiftool' # Capture software metadata from video. Requires ExifTool
# require 'spreadsheet'   Spreadsheet output not implemented yet 
require 'xmlsimple'     # Read data from Sony's XML Exif
require 'find'          # Ruby's Find.find method

# Internal functions and classes

require File.dirname(__FILE__) + '/lib/mediainfo.rb'
require File.dirname(__FILE__) + '/lib/exif.rb'
require File.dirname(__FILE__) + '/lib/client.rb'

# These are the filetypes we consider to be videos
# All others are not videos and we care nothing for them
# Note that we will also scan files with no extensions.
@@filetypes = [ '.mov', '.avi', '.mp4', '.mts' ]

@@files = []    # Let's leave this empty for later
$metadata = []  # This too

case ARGV[0]
  when nil
    puts "usage: metadater <directory>"
    puts "metadater will scan the specified directory and produce YAML output at the end"
    puts "of the process."
  when String
    # Get base directory to scan
    # This directory and all its subdirectories will be scanned
    scandir = Path.new(ARGV[0])
end

scandir.scan
