XMLTEE

This service, hosted at http://xmltee.rumble.net is a helpful way to
test Omniture coding as burnt into the T-Box firmware. It's a very
simple Perl script that accepts an HTTP POST of an XML document,
writes the document to a directory and then on-sends it to the
Omniture servers at info.telstra.com.

A really basic HTML page then includes the directory listing (a
basic Apache feature) so that users can view individual XML documents.

At midnight (Sydney time) a cron job deletes all the files in the
directory.

The system is currently hosted on an Amazon EC2 server, but could
conceivably be served on any web server that can run Perl CGI scripts.
There are no Perl module dependencies.

That's really all there is to it.