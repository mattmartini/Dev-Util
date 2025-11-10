package Dev::Util::Query;

use lib 'lib';
use Dev::Util::Syntax;
use Exporter qw(import);

use Term::ReadKey;
use Term::ANSIColor;
use IO::Interactive qw(is_interactive);
use IO::Prompt      qw();                 # don't import prompt

our $VERSION = version->declare("v2.17.4");

our %EXPORT_TAGS = (
                     misc => [ qw(
                                   banner
                                   display_menu
                                   yes_no_prompt
                                   prompt
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

sub display_menu {
    my $msg         = shift;
    my $choices_ref = shift;

    my %choice_hash = map { $choices_ref->[$_] => $_ } 0 .. $#{ $choices_ref };

    my $chosen = IO::Prompt::prompt(
                                     -prompt => $msg,
                                     -onechar,
                                     -menu    => $choices_ref,
                                     -default => 'a'
                                   );

    return $choice_hash{ $chosen };
}

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
    $msg .= $settings->{ text } || q{};
    $msg .= $ynd;
    $msg .= $settings->{ append };

    return
        IO::Prompt::prompt(
                            -prompt => $msg,
                            -onechar,
                            -default => ( $settings->{ default } ) ? 'Y' : 'N',
                            -yes_no,
                            -require => { "Please choose${ynd}: " => qr/[YN]/i }
                          );
}

sub prompt {
    my ($settings) = @_;

    my $msg = $settings->{ prepend };
    $msg .= $settings->{ text } || q{};
    $msg .= " [$settings->{default}]" if ( defined $settings->{ default } );
    $msg .= $settings->{ append };

    my $prompt_args = { -prompt => $msg };
    if ( $settings->{ noecho } ) { $prompt_args->{ -echo } = q{} }
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

1;    # End of Dev::Util::Query

=pod

=encoding utf-8

=head1 NAME

Dev::Util::Query - General utility functions for programming

=head1 VERSION

Version v2.17.4

=head1 SYNOPSIS

Dev::Util::Query - provides functions to assist working with files and dirs, menus and prompts, and running external programs.

    use Dev::Util::Query;



    banner( "Hello World", $outputFH );

    my $msg    = 'Pick a choice from the list:';
    my @items  = ( 'choice one', 'choice two', 'choice three', );
    my $choice = display_menu( $msg, \@items );


=head1 EXPORT_TAGS

=over 4

=item B<:misc>

=over 8

=item display_menu

=item prompt

=item yes_no_prompt

=item banner

=back

=back

=head1 SUBROUTINES

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


=head1 AUTHOR

Matt Martini, C<< <matt at imaginarywave.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-dev-util at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dev-Util>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Dev::Util::Query

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

=head1 ACKNOWLEDGMENTS

=head1 LICENSE AND COPYRIGHT

This software is Copyright © 2019-2025 by Matt Martini.

This is free software, licensed under:

    The GNU General Public License, Version 3, June 2007

=cut

__END__
