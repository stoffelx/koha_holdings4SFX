package Parsers::PlugIn::KOHA_MLEA;

use base qw(Parsers::PlugIn);
use HTTP::Request;
use LWP::UserAgent;
use URI::URL;
use URI::Escape qw(uri_escape);
use SFXMenu::Debug qw(debug error);
#use Text::Unidecode;

use warnings;

sub lookup {
        my ($self,$ctx_obj)     = @_;

        # start timer
        my $t = Benchmark::Timer->new();
        $t->start;

        # read attributes from context object
        my $btitle              = $ctx_obj->get('rft.btitle');
        my $issn                = $ctx_obj->get('rft.issn');
        my $eissn               = $ctx_obj->get('rft.eissn');
        my $isbn_13             = $ctx_obj->get('rft.isbn_13');
        my $isbn_10             = $ctx_obj->get('rft.isbn_10');
        my $jtitle              = $ctx_obj->get('rft.jtitle');
        my $atitle              = $ctx_obj->get('rft.atitle');

        # define request parameters
        my $url          = "https://demo.kohacatalog.com"; #SPECIFY CATALOGUE BASE URL HERE
        $url            .= "/cgi-bin/koha/opac-search.pl?";

        # set query string
        #
        # preferred btitle consideration to enhance output quality
        if ($btitle){
            if ($isbn_13 && $btitle){
                    $isbn_13 =~ s/-//g;
                    $btitle =~ s/\s/\+/g;
                    $url .= "idx=nb&q=$isbn_13&op=OR&idx=ti&q=" . uri_escape($btitle);
            }
            elsif ($isbn_10 && $btitle){
                    $isbn_10 =~ s/-//g;
                    $btitle =~ s/\s/\+/g;
                    $url .= "idx=nb&q=$isbn_10&op=OR&idx=ti&q=" . uri_escape($btitle);
            }
            else {
                $btitle =~ s/\s/\+/g;
                $url .= "idx=ti%2Cphr&q=" . uri_escape($btitle);
            }
        }
        elsif ($isbn_10 && $isbn_13){
                $isbn_10 =~ s/-//g;
                $isbn_13 =~ s/-//g;
                $url .= "idx=nb&q=$isbn_10&op=OR&idx=nb&q=$isbn_13";
        }
        elsif ($isbn_13 && $issn){
                $isbn_13 =~ s/-//g;
                $url .= "idx=nb&q=$isbn_13&op=OR&idx=ns&q=$issn";
        }
        elsif ($issn && $eissn){
                $url .= "idx=ns&q=$issn&op=OR&idx=ns&q=$eissn";
        }
        elsif ($isbn_10) {
                $isbn_10 =~ s/-//g;
                $url .= "idx=nb&q=$isbn_10";
        }
        elsif ($isbn_13) {
                $isbn_13 =~ s/-//g;
                $url .= "idx=nb&q=$isbn_13";
        }
        elsif ($issn){
                $url .= "idx=ns&q=$issn";
        }
        elsif ($eissn){
                $url .= "idx=ns&q=$issn";
        }
        elsif ($jtitle){
                $jtitle =~ s/\s/\+/g;
                $url .= "idx=ti&q=" . uri_escape($jtitle);
        }
#        elsif ($btitle){
#                $btitle =~ s/\s/\+/g;
#                $url .= "idx=ti%2Cphr&q=" . uri_escape($btitle);
#        }
        elsif ($atitle){
                $atitle =~ s/\s/\+/g;
                $url .= "idx=ti&q=" . uri_escape($atitle);
        }
        else {
                return 0;
        }

        # limit search results to locally available items + set plugin request to RSS output for increased precision at result assessment...
        $url .= "&limit=available&format=rss";
        #

        debug $url;

        # execute HTTP request
        $url                    = new URI::URL($url);
        my $req                 = new HTTP::Request(GET,$url);
        my $ua                  = LWP::UserAgent->new(timeout=>2);
        my $resp                = $ua->request($req);
        my $content             = $resp->content;
        # debug $content;

        # stop timer
        $t->stop;
        debug "Process took: ".$t->results()->[1];
        $t->reset;

        # parse result
        #if (($content =~ /koha:biblionumber/i)) {
        unless (($content =~ /<opensearch:totalResults>0<\/opensearch:totalResults>/i)) {
                return 1;
        }
        else {
                return 0;
        }
}
1;