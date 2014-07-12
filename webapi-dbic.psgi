
use Plack::Builder;
use Plack::App::File;

use Devel::Dwarn;

BEGIN {
    $ENV{WM_DEBUG} ||= 0; # verbose
    $ENV{DBIC_TRACE} ||= 0;
    $ENV{DBI_TRACE} ||= 0;
    $ENV{PATH_ROUTER_DEBUG} ||= 0;
    $|++;
}

my $app = require WebAPI::DBIC::WebApp;

my $app_prefix = "/clients/v1";

builder {
    enable 'SimpleLogger';  # show on STDERR
    #enable "Plack::Middleware::AccessLog", format => '%h %l %u %t "%r" %>s %b %{X-Runtime}o';
    enable "Runtime", header_name => "X-Runtime";
    enable "HTTPExceptions", rethrow => 1;
    #enable "StackTrace", force => 1;

    #enable sub { my $app=shift; sub { Dwarn my $env=shift; my $res = $app->($env); return $res; }; };

    mount "$app_prefix/" => builder {
        mount "/browser" => Plack::App::File->new(root => "hal-browser")->to_app;
        mount "/" => $app;
    };

    # root redirect for discovery - redirect to API
    mount "/" => sub { [ 302, [ Location => "$app_prefix/" ], [ ] ] };
};
