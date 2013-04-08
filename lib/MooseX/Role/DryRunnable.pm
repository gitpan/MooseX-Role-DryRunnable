use strict;
use warnings;
package MooseX::Role::DryRunnable;

use MooseX::Role::Parameterized;
with 'MooseX::Role::DryRunnable::Base';

use namespace::clean -except => 'meta';

our $VERSION = '0.005';

parameter methods => (
  traits  => ['Array'],
  is      => 'ro',
  isa     => 'ArrayRef[Str]',
  default => sub { [] },
  handles => { all_methods => 'elements' },
);

role {
  my $p = shift;
  
  foreach my $method_name ( $p->all_methods() ){
    around $method_name => sub { 
      my $code = shift;
      my $self = shift;

      $self->is_dry_run($method_name,@_) 
        ? $self->on_dry_run($method_name,@_) 
        : $self->$code(@_)  
    }
  }
};

1;

__END__

=head1 NAME

MooseX::Role::DryRunnable - role for add a dry_run (or dryrun) option into your Moose Class

=head1 SYNOPSIS

  package Foo;
  use Moose;

  with 'MooseX::Role::DryRunnable' => { 
    methods => [ qw(bar) ]
  };

  has dry_run => (is => 'ro', isa => 'Bool', default => 0);

  sub bar {
    shift;
    print "Foo::bar @_\n";
  }

  sub is_dry_run { # required !
    $ENV{'DRY_RUN'} || shift->dry_run
  }

  sub on_dry_run { # required !
    my $self   = shift;
    my $method = shift;
    $self->logger("Dry Run method=$method, args: \n", @_);
  }

=head1 DESCRIPTION

This module is a L<Moose> Role who require two methods, `is_dry_run` and `on_dry_run`, the first method return true if we are in this mode (reading from a configuration file, command line option or some environment variable) and the second receive the name of the method and the list of arguments.

=head1 REQUIRES

=head2 is_dry_run (self, method_name, argument_list)

This method will receive the name of the method and the argument list from the original method. Must return a boolean value. If true, we will execute the alternate code described in `on_dry_run`. You must implement!

=head2 on_dry_run (self, method_name, argument_list)

This method will receive the name of the method and the argument list from the original method. You must implement!

=head1 ROLE PARAMETERS 

This Role is Parameterized, and we can choose the set of methods to apply the dry_run capability.

=head2 methods ArrayRef(Str)

This is the set of methods to be changed, must be an array ref of strings. Each method in this parameter will receive an extra code (using Moose 'around') to act as a Dry Run Method.

=head1 SEE ALSO

L<Moose::Role>, L<MooseX::Role::Parameterized>.

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.

Please report problems to Tiago Peczenyj <tiago.peczenyj@gmail.com>, or (preferred)
to this package's RT tracker at <bug-MooseX-Role-DryRunnable@rt.cpan.org>.

=head1 AUTHOR

Tiago Peczenyj <tiago.peczenyj@gmail.com>


=head1 LICENSE AND COPYRIGHT

Copyright (c) 2013 Tiago Peczenyj <tiago.peczenyj@gmail.com>

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself, either Perl version 5.10.0 or, at your option, any later version of Perl 5 you may have available.

=cut