#!/usr/bin/perl

use LWP::UserAgent;
use HTML::Parser ();
use JSON::Parse 'parse_json';
use LWP::Simple 'getstore';

my %hash;
my $filter = undef;

sub html_parse
{
	my ($tag, $attr, $dtext, $origtext) = @_;
	if($tag =~ /^li$/)
	{
		if (defined $attr->{'sound_id'} )
		{
			$sound_id = $attr->{'sound_id'};
		}
	}
	elsif($tag =~ /^a$/)
	{
		if (defined $attr->{'class'}
			&& $attr->{'class'} =~ /^title$/
			&& defined $attr->{'title'}
			&& defined $sound_id)
		{
			my $title = $attr->{'title'};
			if (not defined $filter or $title =~ /$filter/)
			{
				$title =~ s/\ //g;
				$title =~ s/\.mp3//g;
				$title =~ s/[()]//g;
				if ($title !~ /^\d/) {
					my $num = keys %hash;
					$num = $num + 1;
					$title = sprintf("%02d", $num).$title;
				}
				$hash{$sound_id} = $title;
				$sound_id = undef;
			}
		}
	}
}

sub get_info {
	my $url = shift;

	my $ua = LWP::UserAgent->new;
	$ua->timeout(10);
	print "fetching audio list ...\n";
	my $response = $ua->get($url);
	if (!$response->is_success) {
		print "open url $url failed\n";
		exit 1;
	}

	my $sound_id = undef;

	my  $parser = HTML::Parser->new(
		start_h => [\&html_parse, "tagname, attr"],
	);

	$parser->parse($response->content);
	$parser->eof;

	return \%hash;
}

sub get_url {
	my $id = shift;
	my $url = "http://www.ximalaya.com/tracks/".$id.".json";
	my $ua = LWP::UserAgent->new;
	my $response = $ua->get($url);
	if (!$response->is_success) {
		print "open url $url failed\n";
		exit 1;
	}

	my $config = parse_json($response->content);
	if (defined $config
		&& defined $config->{'play_path_32'}) {
		return $config->{'play_path_32'};
	}

	return undef;
}

sub get_url_list {
	print "fetching audio url ...\n";
	my %url_list;
	foreach my $key (keys %hash) {
		my $id = $key;
		my $title = $hash{$key};
		my $sound_url = get_url($id);
		if(defined $sound_url) {
			$url_list{$title} = $sound_url;
		}
	}

	return \%url_list;
}

sub download_m4a {
	my ($url, $title) = @_;
	print "downloading $title.m4a ...\n";
	my $code = getstore($url, $title.".m4a");
	if ($code != 200) {
		print "download $title.m4a failed: $code\n";
		unlink($title.".m4a");
		exit 1;
	}
	return $title;
}

sub convert_m4a_to_mp3 {
	my $title = shift;
	print "converting $title.m4a to $title.mp3 ...\n";
	my $ret = system("/usr/local/bin/ffmpeg -loglevel 24 -i $title.m4a -map 0:a -codec:a libmp3lame -q:a 4 -map_metadata -1 $title.mp3");
	if ($ret != 0) {
		print "convert $title.m4a to $title.mp3 failed\n";
		unlink($title.".m4a");
		unlink($title.".mp3");
		exit 1;
	}
	unlink($title.".m4a");
	return $title.".mp3";
}

sub get_mp3 {
	my $url_list = shift;
	print "starting downloads ...\n";
	foreach my $title (keys %$url_list) {
		my $url = $url_list->{$title};
		if (-f $title.".mp3") {
			print "$title.mp3 exists, skip\n";
		}
		else {
			my $m4a_file = download_m4a($url, $title);
			my $mp3_file = convert_m4a_to_mp3($m4a_file);
			print "$mp3_file generated!\n";
		}
	}
	print "all the operations succeed\n";
}

if (@ARGV eq 0) {
	print "usage: ./ximalaya.pl url [filter]\n";
	exit 0;
}

my $album_url = $ARGV[0];
if (@ARGV ge 2) {
	$filter = $ARGV[1];
}

get_info($album_url);
my $url_list = get_url_list();
get_mp3($url_list);
