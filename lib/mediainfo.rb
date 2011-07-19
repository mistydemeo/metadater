class Video < String

  # This method creates a hash with all of the desired metadata
  # That hash then gets pushed onto an array, with one entry for each
  # file being examined.
  # The array variable is specified when the method is called.

  def examine( array )
    # Call the MediaInfo library to examine technical metadata
    info = Mediainfo.new self

    # Call ExifTool to examine software metadata
    exif = MiniExiftool.new self

    @@general   = {
      :path => f,
      :container => info.general.format,
      :video_tracks => info.video.count,
      :audio_tracks => info.audio.count,
      :duration => info.general.duration,
      :encoded_date => info.general.encoded_date
    }

    # Most videos only contain one video track.

    @@video     = {
      :codec => info.video.format,
      :codec_profile => info.video.format_profile,
      :codec_id => info.video.codec_id,
      :width => info.video.width,
      :height => info.video.height,
      # :standard => TODO,            Write code to handle this
      :aspect_ratio => info.video.display_aspect_ratio,
      :bitrate => info.video.bit_rate,
      :bitrate_mode => info.video.bitrate_mode,
      :colour_space => info.video[0]["color_space"]
      :colour_subsampling => info.video[0]["chroma_subsampling"]
    }

    # We only log metadata from the first audio track,
    # But we will say how many tracks there are.
    @@audio     = {
      :codec => info.audio[0].format,
      :codec_id => info.audio[0].codec_id,
      :sampling_rate => info.audio[0].sampling_rate,
      :channels => info.audio[0].channels,
      :bit_depth => info.audio[0]["bit_depth"]
      :bit_rate => info.audio[0].bit_rate,
      :bit_rate_mode => info.audio[0].bit_rate_mode
    }

    @@software  = {
      :writing_library => info.general.writing_library,
      :software => exif.history_software_agent
    }

    # Push the hash onto the array as a new entry
    # Each new line in the array forms a new row in the spreadsheet,
    # and a new entry in the YAML
    # Remember, .push is destructive! Use with care.

    array.push = {
      :key => f,              # The file path is the key
    #  :md5 => TODO,          MD5 isn't implemented yet
      :general => @@general,
      :video => @@video,
      :audio => @@audio,
      :software => @@software
    }

  end
end
