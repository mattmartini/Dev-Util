package Dev::Util::Utils;

use lib 'lib';
use Dev::Util::Syntax;
use Exporter qw(import);

use File::Temp;
use Term::ReadKey;
use Term::ANSIColor;
use IO::Interactive qw(is_interactive);
use IPC::Cmd        qw[can_run run];

our $VERSION = version->declare("v2.1.6");

our %EXPORT_TAGS = (
                     misc => [ qw(
                                   mk_temp_dir
                                   mk_temp_file
                                   display_menu
                                   prompt
                                   yes_no_prompt
                                   banner
                                   stat_date
                                   status_for
                                   ipc_run_l
                                   ipc_run_s
                               )
                             ],
                   );

# add all the other ":class" tags to the ":all" class, deleting duplicates
{
    my %seen;
    push @{ $EXPORT_TAGS{ all } }, grep { !$seen{ $_ }++ } @{ $EXPORT_TAGS{ $_ } }
        foreach keys %EXPORT_TAGS;
}
Exporter::export_ok_tags('all');

sub mk_temp_dir {

    my $temp_dir = File::Temp->newdir( DIR     => '/tmp',
                                       CLEANUP => 1 );

    return ($temp_dir);
}    # mk_temp_dir

sub mk_temp_file {
    my $temp_dir = shift || '/tmp';

    my $temp_file = File::Temp->new(
                                     DIR    => $temp_dir,
                                     SUFFIX => '.test',
                                     UNLINK => 1
                                   );

    print $temp_file 'super blood wolf moon' . "\n";

    return ($temp_file);
}    # mk_temp_file

sub display_menu {
    my $msg         = shift;
    my (@choices)   = @_;
    my $num_choices = $#choices;
    if ( $num_choices > 36 ) { die "Error: Too many choices in menu.\n" }
    my $j;
    for ( my $i = 0; $i <= $num_choices; $i++ ) {
        if ( $i < 10 ) {
            $j = $i;
        }
        else {
            $j = chr( 87 + $i );
        }
        printf( "  %s - %s\n", $j, $choices[$i] );
    }

    print colored ( $msg, 'blue' );
    return get_keypress($num_choices);
}


sub prompt {
    my ( $msg, $default ) = @_;
    my $str;

    $msg .= " [$default]" if ($default);

    while ( ( $str ne $default ) && !$str ) {
        print "$msg ? ";
        $str = <STDIN>;
        chomp $str;
        $str = ($default) ? $default : $str unless ($str);
    }

    return $str;
}

sub yes_no_prompt {
    my ( $msg, $default ) = @_;
    my $str = '';

    if ( defined $default ) {
        $msg .= ($default) ? ' ([Y]/N)? ' : ' (Y/[N])? ';
    }
    else {
        $msg .= ' (Y/N)? ';
    }

    while ( $str !~ /[yn]/i ) {
        print "$msg";
        $str = <STDIN>;
        chomp $str;
        if ( defined $default ) {
            $str = ($default) ? 'y' : 'n' unless ($str);
        }
    }

    return ( $str =~ /y/i ) ? 1 : 0;
}


sub banner {
    my $banner = shift;
    my $fh     = shift || \*STDOUT;

    my $width;
    if ( is_interactive() ) {
        ($width) = GetTerminalSize();
    }
    else {
        $width = 80;
    }

    my $spacer = ( $width - 2 ) - length($banner);
    my $lspace = int( $spacer / 2 );
    my $rspace = $lspace + $spacer % 2;

    print $fh "#" x $width . "\n";
    print $fh "#" . " " x ( $width - 2 ) . "#" . "\n";
    print $fh "#" . " " x $lspace . $banner . " " x $rspace . "#" . "\n";
    print $fh "#" . " " x ( $width - 2 ) . "#" . "\n";
    print $fh "#" x $width . "\n";
    print $fh "\n";

    return;
}

sub stat_date {
    my $file        = shift;
    my $dir_format  = shift || 0;
    my $date_format = shift || 'daily';
    my ( $date, $format );

    my $mtime = ( stat $file )[9];

    if ( $date_format eq 'monthly' ) {
        $format = $dir_format ? "%04d/%02d" : "%04d%02d";
        $date = sprintf(
                         $format,
                         sub { ( $_[5] + 1900, $_[4] + 1 ) }
                         ->( localtime($mtime) )
                       );
    }
    else {
        $format = $dir_format ? "%04d/%02d/%02d" : "%04d%02d%02d";
        $date = sprintf(
                         $format,
                         sub { ( $_[5] + 1900, $_[4] + 1, $_[3] ) }
                         ->( localtime($mtime) )
                       );
    }
    return $date;
}

sub status_for {
    my ($file) = @_;
    Readonly my @STAT_FIELDS =>
        qw( dev ino mode nlink uid gid rdev size atime mtime ctime blksize blocks );

    # The hash to be returned...
    my %stat_hash = ( file => $file );

    # Load each stat datum into an appropriately named entry of the hash...
    @stat_hash{ @STAT_FIELDS } = stat $file;

    return \%stat_hash;

    # usage: print status_for($file)->{mtime};
}

# execute the cmd and return array of output or undef on failure
sub ipc_run_l {
    my ($arg_ref) = @_;
    $arg_ref->{ debug } ||= 0;
    warn "cmd: $arg_ref->{ cmd }\n" if $arg_ref->{ debug };

    my ( $success, $error_message, $full_buf, $stdout_buf, $stderr_buf )
        = run(
               command => $arg_ref->{ cmd },
               verbose => $arg_ref->{ verbose } || 0,
               timeout => $arg_ref->{ timeout } || 10,
             );

    # each element of $stdout_buf can contain multiple lines
    # flatten to one line per element in result returned
    if ($success) {
        my @result;
        foreach my $lines ( @{ $stdout_buf } ) {
            foreach my $line ( split( /\n/, $lines ) ) {
                push @result, $line;
            }
        }
        return @result;
    }
    return;
}

# execute the cmd return 1 on success 0 on failure
sub ipc_run_s {
    my ($arg_ref) = @_;
    $arg_ref->{ debug } ||= 0;
    warn "cmd: $arg_ref->{ cmd }\n" if $arg_ref->{ debug };

    if (
          scalar run(
                      command => $arg_ref->{ cmd },
                      buffer  => $arg_ref->{ buf },
                      verbose => $arg_ref->{ verbose } || 0,
                      timeout => $arg_ref->{ timeout } || 10,
                    )
       )
    {
        return 1;
    }
    return 0;
}

1;    # End of Dev::Util::Utils

=pod

=encoding utf-8

=head1 NAME

Dev::Util::Utils - General utility functions for programming

=head1 VERSION

Version v2.1.6

=head1 SYNOPSIS

Dev::Util::Utils - provides functions to assist working with files and dirs, menus and prompts, and running external programs.

    use Dev::Util::Utils;

    my $td = mk_temp_dir();
    my $tf = mk_temp_file($td);

    my $file_date     = stat_date( $test_file, 0, 'daily' );    # 20240221
    my $file_date     = stat_date( $test_file, 1, 'monthly' );  # 2024/02

    banner( "Hello World", $outputFH );

    my $msg    = 'Pick a choice from the list:';
    my @items  = ( 'choice one', 'choice two', 'choice three', );
    my $choice = display_menu( $msg, @items );


=head1 EXPORT_TAGS

=over 4

=item B<:misc>

=over 8

=item mk_temp_dir

=item mk_temp_file

=item display_menu

=item get_keypress

=item prompt

=item yes_no_prompt

=item valid

=item banner

=item stat_date

=item status_for

=item ipc_run_l

=item ipc_run_s

=back

=back

=head1 SUBROUTINES

=head2 B<mk_temp_dir>

Create a temporary directory in tmp for use in testing

=head2 B<mk_temp_file>

Create a temporary file in tmp or supplied dir for use in testing

=head2 B<display_menu>

Display a menu of options

=head3 settings

=over 4

=item choices

array of menu items

=back

=head2 B<get_keypress>

Return a single keypress

=head3 settings

=over 4

=item msg

text to display

=item default

default value, if any

=back

=head2 B<prompt>

Prompt user for input

=head3 settings

=over 4

=item msg

text to display

=item default

default value, if any

=back

=head2 B<yes_no_prompt>

boolean prompt

=head3 settings

=over 4

=item msg

text to display

=item default

0 --> no, 1 --> yes, undef --> none

=back

Returns: 1 -- yes, 0 -- no

=head2 B<valid>

helper function for the prompt

returns undef if selection is valid , errmsg if error

=head3 Params

=over 4

=item str

user response

=item valid

either ref_array of valid answers or ref_sub that returns true/false

=item okempty

is empty string ok

=back

=head2 B<banner>

print a banner

=head2 B<stat_date>

return the stat date of a file

   format: YYYYMMDD,
or format: YYYY/MM/DD if dir_format is true
or format: YYYYMM or YYYY/MM if date_type is monthly

=head2 B<status_for>

return hash_ref of file stat info.
print status_for($file)->{mtime}
available keys:
dev ino mode nlink uid gid rdev size atime mtime ctime blksize blocks

=head2 B<ipc_run_l>
Run an external program and return it's output.


=head2 B<ipc_run_s>
Run an external program and return the status of it's execution.

=head1 AUTHOR

Matt Martini, C<< <matt at imaginarywave.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-dev-util at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dev-Util>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Dev::Util::Utils

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Dev-Util>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Dev-Util>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Dev-Util>

=item * Search CPAN

L<https://metacpan.org/release/Dev-Util>

=back

=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

This software is Copyright © 2019-2025 by Matt Martini.

This is free software, licensed under:

    The GNU General Public License, Version 3, June 2007

=cut

__END__
