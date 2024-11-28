package Parsers::TargetParser::KOHA::HOLDING;
use base qw(Parsers::TargetParser);
use Parsers::TargetParser;
#use strict;
use HTTP::Request;
use LWP::UserAgent;
use URI;
use URI::Escape qw(uri_escape);
use URI::URL;
#use Text::Unidecode;

sub     getHolding {
        my ($self,$ctx_obj)     = @_;
        my $btitle              = $ctx_obj->get('rft.btitle');
        my $issn                = $ctx_obj->get('rft.issn');
        my $eissn               = $ctx_obj->get('rft.eissn');
        my $isbn_13             = $ctx_obj->get('rft.isbn_13');
        my $isbn_10             = $ctx_obj->get('rft.isbn_10');
        my $jtitle              = $ctx_obj->get('rft.jtitle');
        my $atitle              = $ctx_obj->get('rft.atitle');

        my $url                 = $ctx_obj->parse_param('url');
        $url                    .= "/cgi-bin/koha/opac-search.pl?";


        if ($isbn_10 || $isbn_13 || $issn || $eissn) {
            $isbn_13 =~ s/-//g;
            $isbn_10 =~ s/-//g;
			
		    my $chkurl = $url . "&idx=nb&q=$isbn_13&op=OR&idx=nb&q=$isbn_10&op=ORidx=ns&q=$issn&op=OR&idx=ns&q=$eissn&format=rss";
				
			$chkurl        = new URI::URL($chkurl);
			my $req        = new HTTP::Request(GET,$chkurl);
            my $ua         = LWP::UserAgent->new(timeout=>2);
            my $resp       = $ua->request($req);
            my $content    = $resp->content;
			
			unless (($content =~ /<opensearch:totalResults>0<\/opensearch:totalResults>/i)) {
				if ($isbn_10 && $isbn_13) {
                    $url .= "&idx=nb&q=$isbn_13&op=OR&idx=nb&q=$isbn_10";
                }
                elsif ($issn && $eissn) {
                    $url .= "&idx=ns&q=$issn&op=OR&idx=ns&q=$eissn";
                }
                elsif ($isbn_13 && $issn) {
                    $url .= "&idx=nb&q=$isbn_13&op=OR&idx=ns&q=$issn";
                }
                elsif ($isbn_10 && $issn) {
                    $url .= "&idx=nb&q=$isbn_10&op=OR&idx=ns&q=$issn";
                }
                elsif ($isbn_13 && $eissn) {
                    $url .= "&idx=nb&q=$isbn_13&op=OR&idx=ns&q=$eissn";
                }
                elsif ($isbn_10 && $eissn) {
                    $url .= "&idx=nb&q=$isbn_10&op=OR&idx=ns&q=$eissn";
                }
                elsif ($isbn_13) {
                    $url .= "&idx=nb&q=$isbn_13";
                }
                elsif ($isbn_10) {
                    $url .= "&idx=nb&q=$isbn_10";
                }
                elsif ($issn) {
                    $url .= "&idx=ns&q=$issn";
                }
                elsif ($eissn) {
                    $url .= "&idx=ns&q=$eissn";
                }
			}
			else {
			    if	($jtitle){
                $jtitle =~ s/\s/\+/g;
                $url .= "idx=ti&q=" . uri_escape($jtitle);
                }
            elsif ($btitle){
                $btitle =~ s/\s/\+/g;
                $url .= "idx=ti%2Cphr&q=" . uri_escape($btitle);
                }
            elsif ($atitle){
                $atitle =~ s/\s/\+/g;
                $url .= "idx=ti&q=" . uri_escape($atitle);
                }
			}
		}
		else {
			if ($jtitle){
                $jtitle =~ s/\s/\+/g;
                $url .= "idx=ti&q=" . uri_escape($jtitle);
            }
            elsif ($btitle){
                $btitle =~ s/\s/\+/g;
                $url .= "idx=ti%2Cphr&q=" . uri_escape($btitle);
            }   
            elsif ($atitle){
                $atitle =~ s/\s/\+/g;
                $url .= "idx=ti&q=" . uri_escape($atitle);
            }
        }
		
		return URI->new("$url");
		
}

1;