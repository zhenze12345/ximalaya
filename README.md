#ximalaya

Download audio file from ximalaya.com, and convert them to mp3.

usage: ./ximalaya.pl url [filter]

A multithread version is located here: https://github.com/zhenze12345/fetch-audio-from-fm/blob/master/ximalaya, it can fetch and convert the audio file faster.

###Usage
The parameter <b>url</b> support two types:

1. album page such as http://www.ximalaya.com/45692914/album/6329320

2. sound page such as http://www.ximalaya.com/45692914/sound/27966292 

The parameter <b>filter</b> means the title of sound contain filter

For example:

./ximalaya.pl http://www.ximalaya.com/11129614/album/2872220 侯景传

will download every the sound with title contain "侯景传"

###Dependencies
<a href="http://search.cpan.org/~oalders/libwww-perl-6.18/lib/LWP/UserAgent.pm">LWP::UserAgent</a>
<a href="http://search.cpan.org/~gaas/HTML-Parser-3.72/Parser.pm">HTML::Parser</a>
<a href="http://search.cpan.org/~bkb/JSON-Parse-0.49/lib/JSON/Parse.pod">JSON::Parse</a>
<a href="http://search.cpan.org/~oalders/libwww-perl-6.18/lib/LWP/Simple.pm">LWP::Simple</a>
