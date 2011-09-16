require 'rubygems'      # When running under 1.8. Who knows?

require 'mediainfo'     # Capture technical metadata from video. Requires MediaInfo
require 'mini_exiftool' # Capture software metadata from video. Requires ExifTool
require 'find'          # Ruby's Find.find method
require 'yaml' unless ARGV.include? '--no-yaml'
require 'json' if ARGV.include? '--json'
require 'digest/md5' unless ARGV.include? '--no-hash'

# Internal functions and classes

require File.dirname(__FILE__) + '/lib/metadata.rb'
require File.dirname(__FILE__) + '/lib/client.rb'

# These are the filetypes we consider to be videos
# All others are not videos and we care nothing for them
# Note that we will also scan files with no extensions.
filetypes = [ '.mov', '.avi', '.mp4', '.m4v', '.flv', '.mpg', '.mpeg', 'm2v', '.mts', '.mkv', '.swf' ]

case ARGV[0]
  when nil
    puts "usage: metadater <directory>"
    puts
    puts "metadater will scan the specified directory and produce YAML and/or JSON output"
    puts "at the end of the process."
    puts
    puts "Options:"
    puts "    --no-hash     Do not calculate an MD5 hash for the scanned files"
    puts "    --full-hash   Hash the complete file. This may take a very long time"
    puts "    --json        Write output as JSON"
    puts "    --no-yaml     Do not write output to YAML"

    exit
  when String
    # Get base directory to scan
    # This directory and all its subdirectories will be scanned
    scandir = Path.new( ARGV[0].chomp '/' )
end

scandir.scan( filetypes )
