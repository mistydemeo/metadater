# Adventures in word wrapping. I found this code online but it's not working
# Don't use for now
# class String
#   def wrap(s, width=78)
#     s.gsub(/(.{1,#{width}})(\s+|\Z)/, "\\1\n")
#   end
# end

class Path < String

  def scan
    path = File::Find.new(
      :pattern  => "*.mov", 
      :follow   => false,
      :path     => self.to_s
    )
  end
end
