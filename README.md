Metadater
=========

Metadater is a simple metadata mass-scanner for video. It's about as simple as can be - you give it a directory, and it finds every video inside it and grabs its metadata. Easy-peasy.

Note that Metadater is in extreme alpha, so it is not yet very configurable. This will change. Note also that I'm a beginner programmer, and my code may be ugly ;) Please help me out and teach me the correct way.

Requirements
------------

- Ruby:
  Ruby 1.8.7 and 1.9.2 are supported. It's primarily been tested against 1.9.2, so let me know if there are any issues with 1.8.
- The following gems:
  - [mediainfo](http://rubygems.org/gems/mediainfo):
    The mediainfo gem interfaces with the commandline MediaInfo utility to extract video metadata. The MediaInfo tool must be installed and must be in your path.
  - [mini\_exiftool](http://rubygems.org/gems/mini_exiftool):
    The mini\_exiftool gem interfaces with the commandline ExifTool utility to extract Exif metadata. You need this installed and in your path too.
  - [xml-simple](http://rubygems.org/gems/xml-simple):
    xml-simple is used to process embedded XML in one edge case. Not usually used.

In Mac OS X or Linux, installing the gem dependencies is as simple as typing gem install mediainfo mini\_exiftool xmlsimple

Use your preferred package manager to install the [MediaInfo](http://mediainfo.sourceforge.net/en) and [ExifTool](http://www.sno.phy.queensu.ca/~phil/exiftool/) utilities.

Usage
-----

ruby metadater.rb \<directory\>

Where \<directory\> is the name of the directory to scan. The search is recursive - any subdirectories within the specified directory will also be scanned.

Options: none, for now.

TODO / Caveats
--------------

- Output is only to YAML right now. Spreadsheet support is coming, other formats by request.
- There are no options, but we could add some.
- The supported extensions are hardcoded right now. These should be a configurable option.
- The camera-related Exif features contain a number of Sony device-specific hacks, which kind of sucks. This should be user-configurable, or another way should be found to capture all of this data regardless of device.

License
-------

License is forthcoming. It will be permissive ;)
