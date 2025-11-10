# NAME

Dev::Util::OS - OS discovery and functions

# VERSION

Version v2.17.4

# SYNOPSIS

OS discovery and functions

    use Disk::SmartTools::OS;

    my $OS = get_os();
    my $hostname = get_hostname();
    my $system_is_linux = is_linux();
    ...

# EXPORT

    get_os
    get_hostname
    is_linux
    is_mac
    is_sunos
    ipc_run_e
    ipc_run_c

# SUBROUTINES

## **get\_os**

Return the OS of the current system.

    my $OS = get_os();

## **get\_hostname**

Return the hostname of the current system.

    my $hostname = get_hostname();

## **is\_linux**

Return true if the current system is Linux.

    my $system_is_linux = is_linux();

## **is\_mac**

Return true if the current system is MacOS (Darwin).

    my $system_is_macOS = is_mac();

## **is\_sunos**

Return true if the current system is SunOS.

    my $system_is_sunOS = is_sunos();

## **ipc\_run\_e**

Run an external program and return the status of it's execution.

## **ipc\_run\_c**

Run an external program, capture its output.  Return the output or return undef on failure.

# AUTHOR

Matt Martini, `<matt at imaginarywave.com>`

# BUGS

Please report any bugs or feature requests to `bug-dev-util at rt.cpan.org`, or through
the web interface at [https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dev-Util](https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dev-Util).  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

# SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Dev::Util::OS

You can also look for information at:

- RT: CPAN's request tracker (report bugs here)

    [https://rt.cpan.org/NoAuth/Bugs.html?Dist=Dev-Util](https://rt.cpan.org/NoAuth/Bugs.html?Dist=Dev-Util)

- CPAN Ratings

    [https://cpanratings.perl.org/d/Dev-Util](https://cpanratings.perl.org/d/Dev-Util)

- Search CPAN

    [https://metacpan.org/release/Dev-Util](https://metacpan.org/release/Dev-Util)

# ACKNOWLEDGMENTS

# LICENSE AND COPYRIGHT

This software is Copyright © 2024-2025 by Matt Martini.

This is free software, licensed under:

    The GNU General Public License, Version 3, June 2007
