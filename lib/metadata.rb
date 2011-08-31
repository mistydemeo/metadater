# This file contains methods which depend heavily on external
# libs such as mediainfo and mini_exiftool

class Video

  attr_accessor :file, :md5, :general, :video, :audio, :software, :hardware, :mediainfo_version, :exiftool_version

  # This method creates an object with all of the desired metadata
  def initialize( path )
    # Let the viewer know what we're up to
    puts "Scanning #{path}"

    @file = path.to_s
    
    # Produce MD5. This is usually *not* a secure identifier against corruption
    # because default behaviour is to hash only part of a file
    @md5 = heuristic_hash( path )

    # Call the MediaInfo library to examine technical metadata
    info = Mediainfo.new path

    # Call ExifTool to examine software metadata
    exif = MiniExiftool.new path

    # Width and height exist in multiple places and we can get stuck
    # without them!!
    # Let's suss them out here and use the local variables elsewhere

    if info.video[0].nil? # We can't get resolution from a video with no video
      width = nil
      height = nil
    else
      width  = if info.video[0].width;  Resolution.new(info.video[0].width);   else Resolution.new(exif.image_width);  end
      height = if info.video[0].height; Resolution.new(info.video[0].height);  else Resolution.new(exif.image_height); end
    end

    # XDCAM videos in QT wrappers include a giant XML string with data
    # not represented elsewhere in the Exif
    # Decode it if present for a couple values we want

    unless exif.com_sony_bprl_mxf_nrtmetadata.nil?
      require 'xmlsimple'

      xml = XmlSimple.xml_in( exif.com_sony_bprl_mxf_nrtmetadata )

      manufacturer = xml['Device'][0]['manufacturer']
      serial       = xml['Device'][0]['serialNo']
      firmware     = xml['Device'][0]['Element']
    end

    @general   = {
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
      @video = nil
    else
    @video     = {
      :codec => info.video.format,
      :codec_profile => info.video.format_profile,
      :codec_id => info.video.codec_id,
      :compressor_name => exif.compressor_name,
      :width => width,
      :height => height,
      :frame_rate => info.video.framerate,
      :interlaced => info.video.interlaced?,
      :standard => height.standard?( info.video.interlaced?, info.video.framerate ),
      :aspect_ratio => info.video.display_aspect_ratio,
      :bitrate => info.video.bit_rate,
      :bitrate_mode => info.video.bit_rate_mode,
      :colour_space => info.video[0]["color_space"],
      :chroma_subsampling => info.video[0]["chroma_subsampling"],
      :track_create_date => info.video.encoded_date,
      :track_modify_date => info.video.tagged_date
    }
    end

    # We only log metadata from the first audio track,
    # But we will say how many tracks there are.
    if info.audio[0].nil?
      @audio = nil
    else
    @audio     = {
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

    @software  = {
      :writing_library => info.general.writing_library,
      :writing_history => exif.history_changed,
      :writing_history_date => exif.history_when,
      :software => exif.history_software_agent
    }

    @hardware = {
      :manufacturer => if manufacturer.nil?; exif.make; else manufacturer; end,
      :model => if exif.model; exif.model; else exif.user_data_prd; end,
      :serial_no => serial,
      :firmware => firmware,
      :aperture => exif.aperture,
      :aperture_setting => exif.aperture_setting,
      :shutter_speed => exif.shutter_speed,
      :gain => exif.gain,
      :exposure => exif.exposure_program,
      :focus => exif.focus,
      :image_stabilization => exif.image_stabilization,
      :gps_version_id => exif.gps_version_id,
      :gps_status => if exif.gps_status == 'Measurement Void'; nil; else exif.gps_status; end,
      :gps_map_datum => exif.gps_map_datum
    }

    @mediainfo_version = Mediainfo.version
    @exiftool_version = exif.exiftool_version

  end

  # Calculates a hash for the video. By default this only scans 
  # portions of the file, because large videos on shared folders 
  # will tend to be very very big and take forever to scan
  # Do *not* rely on these partial hashes to identify corruption!!
  def heuristic_hash( path )

    if File.size?( path ).nil?
      return nil 
    elsif ARGV.include? '--no-hash'     # Don't record a hash
      return 'not recorded'
    elsif ARGV.include? '--full-hash'   # Hash the entire file, no matter how long it takes
      return Digest::MD5.hexdigest IO.binread( path )
    elsif File.size?( path ) < 6291456  # File is too small to seek to 5MB, so hash the whole thing
      return Digest::MD5.hexdigest IO.binread( path )
    else
      return Digest::MD5.hexdigest File.open( path, 'rb' ) { |f| f.seek 5242880; f.read 1048576 }
    end

  end

  def to_hash
    return {
      :file => @file,
      :md5 => @md5,
      :general => @general,
      :video => @video,
      :audio => @audio,
      :software => @software,
      :hardware => @hardware,
      :mediainfo_version => @mediainfo_version,
      :exiftool_version => @exiftool_version
    }
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
