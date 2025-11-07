# NAME

Dev::Util::Query - General utility functions for programming

# VERSION

Version v2.15.4

# SYNOPSIS

Dev::Util::Query - provides functions to assist working with files and dirs, menus and prompts, and running external programs.

    use Dev::Util::Query;



    banner( "Hello World", $outputFH );

    my $msg    = 'Pick a choice from the list:';
    my @items  = ( 'choice one', 'choice two', 'choice three', );
    my $choice = display_menu( $msg, \@items );

# EXPORT\_TAGS

- **:misc**
    - display\_menu
    - prompt
    - yes\_no\_prompt
    - banner

# SUBROUTINES

## **display\_menu(MSG,ITEMS)**

Display a simple menu of options. The choices come from an array.  Returns the index of the choice.

`MSG` a string or variable containing the prompt message to display.

`ITEMS` a reference to an array of the choices to list

    my $msg   = 'Pick one of the suits: ';
    my @items = qw( hearts clubs spades diamonds );
    display_menu( $msg, \@items );

## **prompt**

Prompt user for input

### settings

- msg

    text to display

- default

    default value, if any

## **yes\_no\_prompt**

boolean prompt

### settings

- msg

    text to display

- default

    0 --> no, 1 --> yes, undef --> none

Returns: 1 -- yes, 0 -- no

## **banner**

Print a banner message on the supplied file handle (defaults to `STDOUT`)

    banner( "Hello World", $outputFH );

`$outputFH` is a file handle where the banner will be output

# AUTHOR

Matt Martini, `<matt at imaginarywave.com>`

# BUGS

Please report any bugs or feature requests to `bug-dev-util at rt.cpan.org`, or through
the web interface at [https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dev-Util](https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dev-Util).  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

# SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Dev::Util::Query

You can also look for information at:

- RT: CPAN's request tracker (report bugs here)

    [https://rt.cpan.org/NoAuth/Bugs.html?Dist=Dev-Util](https://rt.cpan.org/NoAuth/Bugs.html?Dist=Dev-Util)

- AnnoCPAN: Annotated CPAN documentation

    [http://annocpan.org/dist/Dev-Util](http://annocpan.org/dist/Dev-Util)

- CPAN Ratings

    [https://cpanratings.perl.org/d/Dev-Util](https://cpanratings.perl.org/d/Dev-Util)

- Search CPAN

    [https://metacpan.org/release/Dev-Util](https://metacpan.org/release/Dev-Util)

# ACKNOWLEDGEMENTS

# LICENSE AND COPYRIGHT

This software is Copyright © 2019-2025 by Matt Martini.

This is free software, licensed under:

    The GNU General Public License, Version 3, June 2007
