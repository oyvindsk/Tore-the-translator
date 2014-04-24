#!/usr/bin/env perl

use v5.18;
use warnings;

use utf8;           # This file is utf8 encoded
use open ':utf8';   # filehandlers opend from now on defaults to utf8
use open ':std';    # enforce this on STD{IN,ERR,OUT} as well..

use Lingua::Translate::Bing;

my $client_id       = shift @ARGV or die usage();
my $client_secret   = shift @ARGV or die usage();

my $translator = Lingua::Translate::Bing->new(client_id => $client_id , client_secret => $client_secret );

my $backup_extension = '.orig';
my $oldargv;
my $backup;
my $line;


LINE: while (<>) {

    $line = $_;

    unless ($oldargv and ($ARGV eq $oldargv) ) {

        unlink($backup) or die $@ if $oldargv;

        $backup = $ARGV . $backup_extension;

        rename($ARGV, $backup);
        open(ARGVOUT, ">$ARGV");
        select(ARGVOUT);
        $oldargv = $ARGV;
    }

    foreach ( /(\p{Han}+)/g ){
        my $eng = $translator->translate($_, "en");
        $line =~ s/$_/$eng/;
        say STDOUT "Translated '$_' to '$eng'";
    }

} continue {
    print $line;	# this prints to original filename
}

unlink($backup) or die $@ if $oldargv;

select(STDOUT);


# print $1 if /(\p{Han}+)/;
#

sub usage {
    "Usage:
        $0 Bing-Client-ID  Bing-Client-Secret File-1 [File-n..]

        Data is read from STDIN if there are no file(s) 
        
        This script uses Bing for the translation, which is currently free for up to 2 million characters per month.
        Sign up at: http://datamarket.azure.com/dataset/bing/microsofttranslator)
        and see http://blogs.msdn.com/b/translation/p/gettingstarted1.aspx\n\n"
}

 
 

