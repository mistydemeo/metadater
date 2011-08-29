# This file contains code for "internal" methods - 
# it doesn't interface with external libs

class Path < String

  def scan
    puts 'Scanning files...'

    files = Find.find( self.to_s ).collect do |path|
      # Skip dirs, symlinks, and .DS_Store noise
      case
      when File.directory?( path ), File.symlink?( path ), File.basename( path )[0] == '.'
        next
      end

      case File.extname( path ).downcase
      when '', *@@filetypes
        path
      else
        next
      end
    end.compact!

    # Examine each file in our @@files array, then
    # produce a new array with their metadata
    videos = files.each.collect { |f| Video.new(f) }

    # OK, we have our metadata in a pretty object now
    # Write to YAML

    File.open( self + '/video.yml', 'w' ).write videos.to_yaml

    puts "YAML written to #{self}/video.yml"
  end

end
