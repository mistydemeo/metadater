class Video < String

  # This method creates a hash with all of the desired metadata
  # That hash then gets pushed onto an array, with one entry for each
  # file being examined.
  # The array variable is specified when the method is called.

  def examine( array )
    # Let the viewer know what we're up to
    puts "Scanning #{self}"

    # Call the MediaInfo library to examine technical metadata
    info = Mediainfo.new self

    # Call ExifTool to examine software metadata
    exif = MiniExiftool.new self

    # Width and height exist in multiple places and we can get stuck
    # without them!!
    # Let's suss them out here and use the local variables elsewhere

    if info.video[0].nil? # We can't get resolution from a video with no video
      @width = nil
      @height = nil
    else
      @width  = if info.video[0].width;  Resolution.new(info.video[0].width);   else Resolution.new(exif.image_width);  end
      @height = if info.video[0].height; Resolution.new(info.video[0].height);  else Resolution.new(exif.image_height); end
    end

    # XDCAM videos in QT wrappers include a giant XML string with data
    # not represented elsewhere in the Exif
    # Decode it if present for a couple values we want

    unless exif.com_sony_bprl_mxf_nrtmetadata.nil?
      xml = XmlSimple.xml_in( exif.com_sony_bprl_mxf_nrtmetadata )

      @manufacturer = xml['Device'][0]['manufacturer']
      @serial       = xml['Device'][0]['serialNo']
      @firmware     = xml['Device'][0]['Element']
    end

    @@general   = {
#      :path => self,
      :movie_name => info.general[0]['movie_name'],
      :container => info.general.format,
      :format_info => info.general.format_info,
      :video_tracks => info.video.count,
      :audio_tracks => info.audio.count,
      :duration => info.general.duration,
      :encoded_date => info.general.encoded_date,
      :modify_date => info.general.tagged_date
    }

    # Most videos only contain one video track.

    if info.video[0].nil?
      @@video = nil
    else
    @@video     = {
      :codec => info.video.format,
      :codec_profile => info.video.format_profile,
      :codec_id => info.video.codec_id,
      :compressor_name => exif.compressor_name,
      :width => @width,
      :height => @height,
      :frame_rate => info.video.framerate,
      :interlaced => info.video.interlaced?,
      :standard => @height.standard?( info.video.interlaced?, info.video.framerate ),
      :aspect_ratio => info.video.display_aspect_ratio,
      :bitrate => info.video.bit_rate,
      # :bitrate_mode => info.video.bitrate_mode,     Not working for now
      :colour_space => info.video[0]["color_space"],
      :chroma_subsampling => info.video[0]["chroma_subsampling"],
      :track_create_date => info.video.encoded_date,
      :track_modify_date => info.video.tagged_date
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
      :bitrate_mode => info.audio[0].bit_rate_mode,
      :track_create_date => info.audio[0].encoded_date,
      :track_modify_date => info.audio[0].tagged_date
    }
    end

    @@software  = {
      :writing_library => info.general.writing_library,
      :writing_history => exif.history_changed,
      :writing_history_date => exif.history_when,
      :software => exif.history_software_agent
    }

    @@hardware = {
      :manufacturer => if @manufacturer.nil?; exif.make; else @manufacturer; end,
      :model => if exif.model; exif.model; else exif.user_data_prd; end,
      :serial_no => @serial if @serial
#      :firmware => exif.software_version,
      :firmware => @firmware,
      :aperture => exif.aperture,
      :aperture_setting => exif.aperture_setting,
      :shutter_speed => exif.shutter_speed,
      :gain => exif.gain,
      :exposure => exif.exposure_program,
      :focus => exif.focus,
      :image_stabilization => exif.image_stabilization,
      :gps_version_id => exif.gps_version_id,
      :gps_status => if exif.gps_status == 'Measurement Void'; nil; else exif.gps_status; end,
      :gps_map_datum => exif.gps_map_datum,
#      :sony_nrt_metadata => exif.com_sony_bprl_mxf_nrtmetadata # Leave this out
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
      :hardware => @@hardware,
      :exiftool_version => exif.exiftool_version
    })

  end
end

  # Comes up with a nice human-readable video standard,
  # e.g. 1080i or 720p or summat
  # Not strictly necessary since we already have the info to
  # generate this, but it's good for humans, and what's good
  # for humans is good for robots too.

class Resolution < DelegateClass(Fixnum)

  def standard?( interlace, framerate )
    case self.to_i
      when 1080
        case interlace 
          when false
            '1080p'
          else
            '1080i'
        end
      when 720
        '720p' # Pretty sure no one records 720i
      when 480
        case interlace
          when true
            if framerate == 29.97; '60i'; else '480i'; end
          else
            '480p'
          end
      end
  end
end
