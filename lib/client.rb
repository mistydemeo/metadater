# Adventures in word wrapping. I found this code online but it's not working
# Don't use for now
# class String
#   def wrap(width=78)
#     self.gsub(/(.{1,#{width}})(\s+|\Z)/, "\\1\n")
#   end
# end

class Path < String

  def scan
    puts 'Scanning files...'

    path = File::Find.new(
      :pattern  => "*.{mov,MOV,avi,AVI,mts,MTS,mp4,MP4}", # Ignore @@filetypes until I figure out the correct clever code to use. Right now will *not* return files without extensions, which we need
      :follow   => false,
      :ftype    => "file",
      :path     => self.to_s
    )

    path.find{ |f|
      @@files.push(f) # Note that this is destructive.
    }

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

    puts 'YAML written to ' + self + '/video.ytml'
  end
end
