#!/usr/bin/env perl

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
Message was send.