#!/usr/bin/env perl
use strict;
use warnings;
use 5.014;
use Mojolicious::Lite;

get '/' => sub {
	my ($self) = @_;
	my $code = $self->param('code');

	$self->render(
		'main',
		code => $code,
		result => q{} . qx{echo "$code" > /tmp/discard},
	);
};

app->config(
	hypnotoad => {
		listen   => ['http://*:3000'],
		pid_file => '/tmp/commanding-bt.pid',
		workers  => 4,
	},
);

app->start;

__DATA__

@@ main.html.ep

<!DOCTYPE html>
<html>
<head>
	<title>wide open web shell</title>
	<link rel="stylesheet" href="style.css">
	<meta charset="UTF-8">
</head>
<body>
%= form_for '/' => begin
%= text_field 'code'
%= submit_button
% end

Result:
<pre>
%= $result;
</pre>

</body>
</html>
