# This file contains code for "internal" methods - 
# it doesn't interface with external libs

class Path < String

  def scan( filetypes )
    puts 'Scanning files...'

    files = Find.find( self.to_s ).collect do |path|
      # Skip dirs, symlinks, and .DS_Store noise
      case
      when File.directory?( path ), File.symlink?( path ), File.basename( path )[0] == '.'
        next
      end

      case File.extname( path ).downcase
      when '', *filetypes
        path
      else
        next
      end
    end.compact!

    # Examine each file in our files array, then
    # produce a new array with their metadata
    videos = files.collect { |f| Video.new( f ).to_hash rescue nil }.compact

    # OK, we have our metadata in a pretty object now
    # Write to YAML & JSON

    File.open( self + '/video.yml', 'w' ).write videos.to_yaml unless ARGV.include? '--no-yaml'
    File.open( self + '/video.json', 'w' ).write JSON.pretty_generate videos if ARGV.include? '--json'

    puts "YAML written to #{self}/video.yml" unless ARGV.include? '--no-yaml'
    puts "JSON written to #{self}/video.json" if ARGV.include? '--json'
  end

end
