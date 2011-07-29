# Adventures in word wrapping. I found this code online but it's not working
# Don't use for now
# class String
#   def wrap(width=78)
#     self.gsub(/(.{1,#{width}})(\s+|\Z)/, "\\1\n")
#   end
# end

class Path < String

  def scan

    # Blank @@files in case it had something in it
    @@files = []
    
    puts 'Scanning files...'

    Find.find( self.to_s ) do |path|
      # Skip dirs, symlinks, and .DS_Store noise
      case
      when File.directory?( path ), File.symlink?( path ), path.include?( 'DS_Store' )
        next
      end

      case File.extname( path ).downcase
      when *@@filetypes, ''
        @@files.push path
      else
        next
      end
    end
        

    # Examine each file in our @@files array, then
    # produce a new array with their metadata
    @@files.each do |f|
      Video.new(f).examine( $metadata )
    end

    # OK, we have our metadata in a pretty object now
    # Write to YAML

    File.open( self + '/video.yml', 'w' ) do |f|
      f.write($metadata.to_yaml)
    end

    puts "YAML written to #{self}/video.yml"
  end
end
