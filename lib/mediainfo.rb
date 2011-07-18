class Video < String

  def examine
    # Call the MediaInfo library to examine technical metadata
    info = Mediainfo.new self

    # Call ExifTool to examine software metadata
    exif = MiniExiftool.new self

    @@general   = { :path => f, :container => info.general.format, :duration => info.general.duration, :encoded_date => info.general.encoded_date }
    @@video     = { :codec => info.video.format, :codec_profile => info.video.format_profile, :codec_id => info.video.codec_id, :width => info.video.width, :height => info.video.height, :standard => TODO, :aspect_ratio => info.video.display_aspect_ratio, :bitrate => info.video.bit_rate, :bitrate_mode => info.video.bitrate_mode, :colour_space => TODO, :colour_subsampling => TODO }
    @@audio     = { :codec => info.audio.format, :codec_id => info.audio.codec_id, :sampling_rate => info.audio.sampling_rate, :channels => info.audio.channels, :bit_depth => TODO, :bit_rate => info.audio.bit_rate, :bit_rate_mode => info.audio.bit_rate_mode }
    @@software  = { :writing_library => info.general.writing_library, :software => exif.history_software_agent } 
