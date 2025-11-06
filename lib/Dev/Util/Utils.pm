package Dev::Util::Utils;

use lib 'lib';
use Dev::Util::Syntax;
use Exporter qw(import);

use File::Temp;
use Term::ReadKey;
use Term::ANSIColor;
use IO::Interactive qw(is_interactive);
use IO::Prompt      qw();                 # don't import prompt
use IPC::Cmd        qw[can_run run];

our $VERSION = version->declare("v2.12.4");

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
                                   read_list
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
    my $dir = shift || '/tmp';
    my $temp_dir = File::Temp->newdir( DIR     => $dir,
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
}

sub display_menu {
    my $msg         = shift;
    my $choices_ref = shift;

    my %choice_hash = map { $choices_ref->[$_] => $_ } 0 .. $#{ $choices_ref };

    my $chosen = IO::Prompt::prompt(
                                     $msg,
                                     -onechar,
                                     -menu    => $choices_ref,
                                     -default => 'a'
                                   );

    return $choice_hash{ $chosen };
}

sub prompt {
    my ($settings) = @_;

    my $msg = $settings->{ prepend };
    $msg .= $settings->{ text } || '';
    $msg .= " [$settings->{default}]" if ( defined $settings->{ default } );
    $msg .= $settings->{ append };

    my $prompt_args = { -prompt => $msg };
    if ( $settings->{ noecho } ) { $prompt_args->{ -echo } = '' }
    ## if ( $settings->{ okempty } ) { ... }    # TODO: figure out okempty sol'n
    if ( defined $settings->{ default } ) {
        $prompt_args->{ -default } = $settings->{ default };
    }
    if ( defined $settings->{ valid } ) {
        if ( ref( $settings->{ valid } ) eq 'ARRAY' ) {
            $prompt_args->{ -menu }     = $settings->{ valid };
            $prompt_args->{ -one_char } = $msg;
        }
        elsif ( ref( $settings->{ valid } ) eq 'CODE' ) {

            # $prompt_args->{ -require } = { '%s (dir must exist): ' => \&dir_writable };
            $prompt_args->{ -require }
                = { '%s (response not valid): ' => $settings->{ valid } };
        }
        else {
            croak "Validitiy test malformed.\n";
        }
    }
    my $response = IO::Prompt::prompt($prompt_args);
    print "\n" if ( exists $settings->{ noecho } );

    return $response->{ value };
}

# TODO: must reverse logic of calls to valid

# Maintain API for existing code even thought changing to IO::Prompt
sub yes_no_prompt {
    my ($settings) = @_;
    my $ynd;

    if ( exists $settings->{ default } ) {
        $ynd = ( $settings->{ default } ) ? ' ([Y]/N)' : ' (Y/[N])';
    }
    else {
        $ynd = ' (Y/N)';
    }

    my $msg = $settings->{ prepend };
    $msg .= $settings->{ text } || '';
    $msg .= $ynd;
    $msg .= $settings->{ append };

    return
        IO::Prompt::prompt(
                            $msg,
                            -onechar,
                            -default => ( $settings->{ default } ) ? 'Y' : 'N',
                            -yes_no,
                            -require => { "Please choose$ynd: " => qr/[YN]/i }
                          );
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

sub read_list {
    my $input_file = shift;
    my $sep        = shift || "\n";

    $sep = undef if ( !wantarray );
    local $INPUT_RECORD_SEPARATOR = $sep;

    my ( $line, @list );

    open( my $input, '<', $input_file )
        or die "can't open file, $input_file $!\n";
    LINE:
    while ( defined( $line = <$input> ) ) {
        chomp($line);
        next LINE if ( $line =~ m|^$| );    # remove blank lines
        next LINE if ( $line =~ m|^#| );    # remove comments
        push @list, $line;
    }
    close($input);

    return wantarray ? @list : $list[0];
}

1;    # End of Dev::Util::Utils

=pod

=encoding utf-8

=head1 NAME

Dev::Util::Utils - General utility functions for programming

=head1 VERSION

Version v2.12.4

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
    my $choice = display_menu( $msg, \@items );


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

=item banner

=item stat_date

=item status_for

=item ipc_run_l

=item ipc_run_s

=back

=back

=head1 SUBROUTINES

=head2 B<mk_temp_dir(DIR)>

Create a temporary directory in the supplied parent dir. F</tmp> is the default if no dir given.

C<DIR> a string or variable pointing to a directory.

    my $td = mk_temp_dir();

=head2 B<mk_temp_file(DIR)>

Create a temporary file in the supplied dir. F</tmp> is the default if no dir given.

    my $tf = mk_temp_file($td);

=head2 B<display_menu(MSG,ITEMS)>

Display a simple menu of options. The choices come from an array.  Returns the index of the choice.

C<MSG> a string or variable containing the prompt message to display.

C<ITEMS> a reference to an array of the choices to list

    my $msg   = 'Pick one of the suits: ';
    my @items = qw( hearts clubs spades diamonds );
    display_menu( $msg, \@items );


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


=head2 B<banner>

Print a banner message on the supplied file handle (defaults to C<STDOUT>)

    banner( "Hello World", $outputFH );

C<$outputFH> is a file handle where the banner will be output

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

=head2 B<read_list>
read a list from an input file rtn an array of lines

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
