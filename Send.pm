package App::HL7::Send;

# Pragmas.
use strict;
use warnings;

# Modules.
use Class::Utils qw(set_params);
use Error::Pure qw(err);
use Getopt::Std;
use Net::HL7::Connection;
use Net::HL7::Message;
use Perl6::Slurp qw(slurp);

# Version.
our $VERSION = 0.01;

# Constructor.
sub new {
	my ($class, @params) = @_;

	# Create object.
	my $self = bless {}, $class;

	# Process params.
	set_params($self, @params);

	# Process arguments.
	$self->{'_opts'} = {
		'h' => 0,
	};
	if (! getopts('h', $self->{'_opts'}) || @ARGV < 3
		|| $self->{'_opts'}->{'h'}) {

		print STDERR "Usage: $0 [-h] [--version] host port hl7_file\n";
		print STDERR "\t-h\t\tHelp.\n";
		print STDERR "\t--version\tPrint version.\n";
		exit 1;
	}
	$self->{'_hl7_host'} = $ARGV[0];
	$self->{'_hl7_port'} = $ARGV[1];
	$self->{'_hl7_file'} = $ARGV[2];

	# Object.
	return $self;
}

# Run.
sub run {
	my $self = shift;

	# Get hl7_file.
	my $hl7 = slurp($self->{'_hl7_file'});

	# Create message.
	my $msg = Net::HL7::Message->new($hl7);
	if (! $msg) {
		err 'Cannot parse HL7 file.', 'File', $self->{'_hl7_file'};
	}

	# Create connection.
	my $conn = Net::HL7::Connection->new($self->{'_hl7_host'},
		$self->{'_hl7_port'});
	if (! $conn) {
		err 'Cannot connect to host.';
	}

	# Send.
	$conn->send($msg);
	print "Message was send.\n";

	return;
}

1;


__END__

=pod

=encoding utf8

=head1 NAME

App::HL7::Send - Base class for hl7send script.

=head1 SYNOPSIS

 use App::HL7::Send;
 my $app = App::HL7::Send->new;
 $app->run;

=head1 METHODS

=over 8

=item C<new()>

 Constructor.

=item C<run()>

 Run method.
 Returns undef.

=back

=head1 ERRORS

 new():
         Cannot process any action.
         From Class::Utils::set_params():
                 Unknown parameter '%s'.

=head1 EXAMPLE

 # Pragmas.
 use strict;
 use warnings;

 # Modules.
 use App::HL7::Send;
 use File::Temp qw(tempfile);
 use IO::Barf qw(barf);

 # Test data.
 my $hl7 = <<'END';
 MSH|^~\&|FROM|Facility #1|TO|Facility #2|20160403211012||ORM^O01|MSGID20160403211012|P|1.0
 PID|||11111||Novak^Jan^^^Ing.||19680821|M|||Olomoucká^^Brno^^61300^Czech Republic|||||||
 PV1||O|OP^PAREG^||||1234^Clark^Bob|||OP|||||||||2|||||||||||||||||||||||||20160403211012|
 ORC|NW|20160403211012
 OBR|1|20160403211012||003038^Urinalysis^L|||20160403211012
 END

 # Barf to temp file.
 my (undef, $file) = tempfile();
 barf($file, $hl7);

 # Arguments.
 @ARGV = (
         'localhost',
         2757,
         $file,
 );

 # Run.
 App::HL7::Send->new->run;

 # Output:
 # TODO

=head1 DEPENDENCIES

L<Class::Utils>,
L<Error::Pure>,
L<Getopt::Std>,
L<Net::HL7::Connection>,
L<Net::HL7::Message>,
L<Perl6::Slurp>.

=head1 REPOSITORY

L<https://github.com/tu pinek/App-HL7-Send>

=head1 AUTHOR

Michal Špaček L<mailto:skim@cpan.org>

L<http://skim.cz>

=head1 LICENSE AND COPYRIGHT

 © 2016 Michal Špaček
 BSD 2-Clause License

=head1 VERSION

0.01

=cut
