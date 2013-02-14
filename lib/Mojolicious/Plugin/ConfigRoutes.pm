package Mojolicious::Plugin::ConfigRoutes;
use Mojo::Base 'Mojolicious::Plugin';

use File::Spec::Functions 'file_name_is_absolute';

our $VERSION = 0.01;

sub register {
  my ($self, $app, $conf) = @_;
  my $r = $app->routes;# Router
  
  my @routes;
  if (ref($conf) eq 'HASH') {
	if ($conf->{'file'}) {
		$conf->{file} = $app->home->rel_file($conf->{file}) unless file_name_is_absolute $conf->{file};
		my @do;
		if (-e $conf->{file}) {@do = do $conf->{file};}
		else {die qq{Config routes file [$conf->{file}] missing, maybe you need to create it?\n};}
		my $do = {@do} if @do > 1; # вернулся список, тогда ключ=>значение
		$do = $do[0] if @do == 1;
		
		if (ref($do) eq 'HASH') {
			push @{$conf->{namespaces}}, @{$do->{namespaces}} if $do->{namespaces} && ref($do->{namespaces}) eq 'ARRAY';# общее переключение папка с контроллерами маршрутов
			push @{$conf->{routes}}, @{$do->{routes}} if $do->{routes} && ref($do->{routes}) eq 'ARRAY';
		} elsif (ref($do) eq 'ARRAY') {# просто маршруты [...]
			push @{$conf->{routes}}, @$do;
		}
	}
	if ($conf->{routes}) {
		push @routes, @{$conf->{routes}};
	}
	$r->namespaces($conf->{namespaces}) if $conf->{namespaces};
	
  } elsif (ref($conf) eq 'ARRAY') {
	push @routes, @$conf;
  }
  
  
  for my $t (@routes) {
    my $_r = $r;# будет цепочка объектов для маршрута
    for( my $i = 0; $i < @$t; $i += 2 ) {
      my $m = $t->[$i]; # method
      my $a = $t->[$i+1];# args to meth
      if (my $meth = $_r->can($m)) {
        #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! НЕЛЬЗЯ ИСПОЛЬЗОВАТЬ $_r!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        #~ $app->log->debug("Apply method for $_r->$m(", (map {"\t'".join("' => '", grep {defined;} @$a[($_*2)..($_*2+1)])."',"} (0..($#$a/2))), ")",);#$app->dumper($a),
        $_r = $_r->$meth(ref($a) ? (ref($a) eq 'ARRAY' ? @$a : %$a) : $a);# apply method
      } else {
        $app->log->warn("Can't method [$m] for [$_r]",);#, will be applied as attr
      }
    }
  }
  
  $app->log->debug("Маршруты: ", $app->dumper($r));
}

=encoding utf8

=head1 ПРИВЕТСТВИЕ SALUTE
 
Доброго всем! Доброго здоровья! Доброго духа!
 
Hello all! Nice health! Good thinks!

¡ ¡ ¡ ALL GLORY TO GLORIA ! ! !

=head1 NAME

Mojolicious::Plugin::ConfigRoutes - is a Perl-ish configuration of routes plugin.

=head1 VERSION

Version 0.01

=head1 SYNOPSIS


    $app->plugin(ConfigRoutes =>{...});
    $app->plugin(ConfigRoutes =>[[...], [...], ..., [...],]);
    ...

This plugin can launch many times.

Array ref of array refs is arranged description of routes. The format is described on option routes below.

Hash ref has the following options.
 
=head1 OPTIONS

L<Mojolicious::Plugin::ConfigRoutes> supports the following options.

=head2 file

File name or full path to configuration file that do and must return list, array ref or hash ref.

    $app->plugin(ConfigRoutes =>{file => 'ConfigRoutes.pm'});


=over 4

=item * Returned list would be consider as pairs of key=>value. Keys are namespaces and routes. Values are arranged array refs, see options below.

=item * Returned array ref would be consider as arranged routes, see format on option routes below.

=item * Returned hash ref with pairs of key=>value. Keys are namespaces and routes. Values are arranged array refs, see options below.

=back

=head2 routes

Value is array ref of the arranged routes [[<route 1>],[<route 2>],...[<route N>],]:

    $app->plugin(ConfigRoutes =>{routes => [[<method1 of module Mojolicious::Routes::Route> => <value>, <method2 of module Mojolicious::Routes::Route> => <value>, ... ],...]});

Methods of Mojolicious::Routes::Route as keys in one route must be strongly arranged pairs with their values in order to apply to $app->routes object. For example:

    # the standard
    $r->bridge('/foo')->to('foo#foo')->route('/bar')->to(controller=>'bar', action=>'bar',...)->...;
    $r-><next route>;
    ...
    # becomes structure
    $app->plugin(ConfigRoutes =>{routes => [[bridge=>'/foo', to=>'foo#for', route=>'/bar', to=>{controller=>'bar', action=>'bar',...}, ...], [<next route>], ...]);
    

Values of keys(methods) within route can be scalar or [array ref] or {hash ref}. Array ref and hash ref are treated as lists when apply to their methods.


=head2 namespaces

Value is array ref of L<http://mojolicio.us/perldoc/Mojolicious/Routes#namespaces>

    $app->plugin(ConfigRoutes =>{namespaces => ['Foo::Bar::Controller']});

=head1 AUTHOR

Mikhail Che, C<< <mche [пёсик] aukama.dyndns.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-mojolicious-plugin-configroutes at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Mojolicious-Plugin-ConfigRoutes>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Mojolicious::Plugin::ConfigRoutes


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Mojolicious-Plugin-ConfigRoutes>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Mojolicious-Plugin-ConfigRoutes>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Mojolicious-Plugin-ConfigRoutes>

=item * Search CPAN

L<http://search.cpan.org/dist/Mojolicious-Plugin-ConfigRoutes/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Mikhail Che.


=cut



1;