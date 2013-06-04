#!/usr/bin/env perl
use strict;
use warnings;
use 5.014;
use Mojolicious::Lite;

my $cache = '/tmp/vuln-upload';

post '/ok' => sub {
	my ($self) = @_;

	if ( my $upload = $self->req->upload('file') ) {
		my $name = $upload->filename;

		if ( not -d $cache ) {
			mkdir($cache);
		}
		$upload->move_to("${cache}/${name}");

		# try really hard to be exploitable
		chmod( 0755, "${cache}/${name}" );

		# FIXME don't hardcode host and port
		$self->stash(
			filename => $name,
			url      => "http://127.0.0.1:3000/get/${name}",
		);
	}
	else {
		$self->render('form');
	}
};

any '/' => 'landing';
any '/add' => 'form';
any '/get/:file' => sub {
	my ($self) = @_;
	my $file = $self->stash('file');

	$self->render( text => q{result: } . qx{$cache/$file} );

};

$ENV{MOJO_MAX_MESSAGE_SIZE} = 52428800;

app->config(
	hypnotoad => {
		listen   => ['http://*:3000'],
		pid_file => '/tmp/upload-exec.pid',
		workers  => 4,
	},
);

app->start;

__DATA__

@@ form.html.ep
<!doctype html><html>
<head><title>Upload</title>
<meta charset="UTF-8"></head>
<body>
<div>
%= form_for ok => (method => 'post', enctype => 'multipart/form-data') => begin
%= file_field 'file';
%= submit_button 'Upload';
% end
</div>
</body>
</html>

@@ ok.html.ep
<!doctype html><html>
<head><title>OK</title><meta charset="UTF-8"></head>
<body>
<div>
<p>
OK Upload <%= $filename %>
</p>
<p>
The file is now available as
<a href="<%= $url %>"><%= $url %></a>
</p>
</div>
</body>
</html>

@@ landing.html.ep
<!doctype html><html>
<head><title>Wide Open Uploader</title><meta charset="UTF-8"></head>
<body>
<div>
<p>
Welcome to an insecure web application
</p>
<p>
Hello w3af, try <a href="/add">adding a file</a>.
</p>
</div>
</body>
</html>
