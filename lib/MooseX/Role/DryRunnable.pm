use strict;
use warnings;
package MooseX::Role::DryRunnable;

use MooseX::Role::Parameterized;

use namespace::clean -except => 'meta';

our $VERSION = '0.001';

parameter methods => (
  traits  => ['Array'],
  is      => 'ro',
  isa     => 'ArrayRef[Str]',
  default => sub { [] },
  handles => { all_methods => 'elements' },
);

role {
  my $p = shift;
  
  requires 'is_dry_run';
  requires 'on_dry_run';
  
  foreach my $method ($p->all_methods){
    around $method => sub { 
        my $code   = shift;
        my $target = shift;

        die "Target does not MooseX::Role::DryRunnable" 
          unless $target->DOES('MooseX::Role::DryRunnable');

        $target->is_dry_run() 
          ? $target->on_dry_run($method,@_) 
          : $code->($target, @_)  
      }
  }
};

1;

__END__

=head1 NAME

MooseX::Role::DryRunnable - role for add a dry_run option into your Moose Class

=head1 SYNOPSIS

  package Foo;
  use Data::Dumper;
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
    shift->dry_run
  }

  sub on_dry_run { # required !
    my $self   = shift;
    my $method = shift;
    $self->logger("Dry Run method=$method, args: \n", @_);
  }

=head1 DESCRIPTION

This module is a L<Moose> Role who require two methods, `is_dry_run` and `on_dry_run`, the first method return true if we are in this mode (reading from a configuration file, command line option or some environment variable) and the second receive the name of the method and the list of arguments.

=head1 ROLE PARAMETERS 

This Role is Parameterized, and we can choose the set of methods to apply the dry_run capability.

=head2 methods (ArrayRef[Str])

This is the set of methods to be changed. Each method in this parameter will receive an extra code (using Moose 'around') to act as a Dry Run Method.

=head1 SEE ALSO

L<Moose::Role>, L<MooseX::Role::Parameterized>.

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.

Please report problems to Tiago Peczenyj <tiago.peczenyj@gmail.com>, or (preferred)
to this package's RT tracker at <bug-MooseX-Role-DryRunnable@rt.cpan.org>.

=head1 AUTHOR

Tiago Peczenyj <tiago.peczenyj@gmail.com>


=head1 LICENSE AND COPYRIGHT

Copyright (c) 2023 Tiago Peczenyj <tiago.peczenyj@gmail.com>

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the

    Free Software Foundation, Inc.
    59 Temple Place, Suite 330
    Boston, MA  02111-1307  USA

=cut