class Video < String

  # This method creates a hash with all of the desired metadata
  # That hash then gets pushed onto an array, with one entry for each
  # file being examined.
  # The array variable is specified when the method is called.

  def examine( array )
    # Let the viewer know what we're up to
    puts 'Scanning ' + self

    # Call the MediaInfo library to examine technical metadata
    info = Mediainfo.new self

    # Call ExifTool to examine software metadata
    exif = MiniExiftool.new self

    @@general   = {
#      :path => self,
      :container => info.general.format,
      :video_tracks => info.video.count,
      :audio_tracks => info.audio.count,
      :duration => info.general.duration,
      :encoded_date => info.general.encoded_date
    }

    # Most videos only contain one video track.

    if info.video[0].nil?
      @@video = nil
    else
    @@video     = {
      :codec => info.video.format,
      :codec_profile => info.video.format_profile,
      :codec_id => info.video.codec_id,
      :width => info.video.width,
      :height => info.video.height,
      # :standard => TODO,            Write code to handle this
      :aspect_ratio => info.video.display_aspect_ratio,
      :bitrate => info.video.bit_rate,
      # :bitrate_mode => info.video.bitrate_mode,     Not working for now
      :colour_space => info.video[0]["color_space"],
      :colour_subsampling => info.video[0]["chroma_subsampling"]
    }
    end

    # We only log metadata from the first audio track,
    # But we will say how many tracks there are.
    if info.audio[0].nil?
      @@audio = nil
    else
    @@audio     = {
      :codec => info.audio[0].format,
      :codec_id => info.audio[0].codec_id,
      :sampling_rate => info.audio[0].sampling_rate,
      :channels => info.audio[0].channels,
      :bit_depth => info.audio[0]["bit_depth"],
      :bitrate => info.audio[0].bit_rate,
      :bitrate_mode => info.audio[0].bit_rate_mode
    } unless info.audio[0].nil?
    end

    @@software  = {
      :writing_library => info.general.writing_library,
      :software => exif.history_software_agent
    }

    @@hardware = {
      :manufacturer => exif.make,
      :model => exif.model,
      :aperture => exif.aperture,
      :aperture_setting => exif.aperture_setting,
      :shutter_speed => exif.shutter_speed,
      :gain => exif.gain,
      :exposure => exif.exposure_program,
      :focus => exif.focus,
      :image_stabilization => exif.image_stabilization
    }


    # Push the hash onto the array as a new entry
    # Each new line in the array forms a new row in the spreadsheet,
    # and a new entry in the YAML
    # Remember, .push is destructive! Use with care.

    array.push ({
      :file => self.to_s,              # The file path is the key
    #  :md5 => TODO,          MD5 isn't implemented yet
      :general => @@general,
      :video => @@video,
      :audio => @@audio,
      :software => @@software,
      :hardware => @@hardware
    })

  end
end
