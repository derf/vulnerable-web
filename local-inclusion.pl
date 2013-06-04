#!/usr/bin/env perl
use strict;
use warnings;
use 5.014;
use File::Slurp qw(slurp);
use Mojolicious::Lite;

get '/' => sub {
	my ($self) = @_;
	my $site = $self->param('site');

	$self->render( 'main',
		source => slurp( $site, err_mode => 'quiet' ) // q{}, );
};

app->config(
	hypnotoad => {
		listen   => ['http://*:3000'],
		pid_file => '/tmp/local-inclusion.pid',
		workers  => 4,
	},
);

app->start;

__DATA__

@@ main.html.ep

<!DOCTYPE html>
<html>
<head>
	<title>wide open source viewer</title>
	<meta charset="UTF-8">
</head>
<body>

<p>
Select a file to view:
<ul>
<li><a href="?site=commanding.pl">OS Commanding</a></li>
<li><a href="?site=commanding-backtick.pl">OS Commanding (silent)</a></li>
</ul>
</p>

<div>
Source browser:
<pre>
%= $source
</pre>
</div>

</body>
</html>
