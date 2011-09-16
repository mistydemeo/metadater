Metadater
=========

Metadater is a simple metadata mass-scanner for video. It's about as simple as can be - you give it a directory, and it finds every video inside it and grabs its metadata. Easy-peasy.

Note that Metadater is in extreme alpha, so it is not yet very configurable. This will change. Note also that I'm a beginner programmer, and my code may be ugly ;) Please help me out and teach me the correct way.

Requirements
------------

- Ruby:<br />
  Ruby 1.9.2 and 1.8.7 are supported (but see below for known issues with 1.8.7). It's primarily been tested against 1.9.2, so let me know if there are any issues with 1.8. When using 1.8, ensure that RubyGems is installed too.
- The following gems:
  - [mediainfo](http://rubygems.org/gems/mediainfo):<br />
    The mediainfo gem interfaces with the commandline MediaInfo utility to extract video metadata. The MediaInfo tool must be installed and must be in your path.
  - [mini\_exiftool](http://rubygems.org/gems/mini_exiftool):<br />
    The mini\_exiftool gem interfaces with the commandline ExifTool utility to extract Exif metadata. You need this installed and in your path too.
  - [xml-simple](http://rubygems.org/gems/xml-simple):<br />
    xml-simple is used to process embedded XML in one edge case. Not usually used.

In Mac OS X or Linux, installing the gem dependencies is as simple as typing *gem install mediainfo mini\_exiftool xmlsimple*

Use your preferred package manager to install the [MediaInfo](http://mediainfo.sourceforge.net/en) and [ExifTool](http://www.sno.phy.queensu.ca/~phil/exiftool/) utilities.

Usage
-----

ruby metadater.rb \<directory\> [options]

Where \<directory\> is the name of the directory to scan. The search is recursive - any subdirectories within the specified directory will also be scanned. When the search completes, a file named video.yml and/or video.json will be dropped into the scanned directory.

Options:

--no-hash   Do not calculate hashes for videos<br />
--full-hash Calculate the MD5 hash using the video's full data, rather than part of it. Note that this may be *very* slow.
--json      Write JSON output. This is faster to write and to parse, but far less human-readable.
--no-yaml   Skip writing YAML output.

TODO / Caveats
--------------

- Output is only to YAML and JSON right now. Report generation is coming, other formats by request.
- By default, the MD5 is hashed for a one-megabyte section beginning 5MB into the file. This is *not* a secure method of identifying corruption, and is meant only as a convenience for identifying files in conjunction with filesize. This option was chosen because calculating complete hashes for multi-gigabyte videos can take hours, especially if they are on a device with limited read speed such as a network drive.
- There are no options beyond MD5-related options, but we could add some.
- The supported extensions are hardcoded right now. These should be a configurable option.
- The camera-related Exif features contain a number of Sony device-specific hacks, which kind of sucks. This should be user-configurable, or another way should be found to capture all of this data regardless of device.
- Fix Ruby 1.8-specific issues.
  - Ruby 1.8 hashes are unordered, so fields are in alphabetical rather than logical order in the output YAML
  - Non-video files which begin with a period are not skipped in 1.8

License
-------

Metadater is licensed under the 2-clause BSD license ("FreeBSD License"). For the text of the license, see LICENSE.
