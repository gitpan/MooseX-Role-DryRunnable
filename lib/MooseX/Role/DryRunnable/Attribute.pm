use strict;
use warnings;
package MooseX::Role::DryRunnable::Attribute;
use Moose::Util;
use Attribute::Handlers;

our $VERSION = '0.001';

sub UNIVERSAL::dry_it :ATTR(CODE) { 
  my $package = shift;
  my $glob    = shift;
  my $method  = *{$glob}{NAME};
  
  Moose::Util::add_method_modifier($package => around => [ $method => sub { 
      my $code   = shift;
      my $target = shift;

      die "Should be MooseX::Role::DryRunnable\n" 
        unless $target->DOES('MooseX::Role::DryRunnable');

      $target->is_dry_run() 
        ? $target->on_dry_run($method,@_) 
        : $code->($target, @_)
      }
  ]);
}

1;

__END__

=head1 NAME

MooseX::Role::DryRunnable::Attribute - EXPERIMENTAL - attribute to add a Dry Run Capability in some methods

=head1 SYNOPSIS

  package Foo;
  use Data::Dumper;
  use Moose;
  use MooseX::Role::DryRunnable::Attribute;
  with 'MooseX::Role::DryRunnable';

  has dry_run => (is => 'ro', isa => 'Bool', default => 0);

  sub bar :dry_it {
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

This module can be used in Moose classes who uses the role MooseX::Role::DryRunnable. Provides an Attribute :dry_it. EXPERIMETAL

My idea is put the information about the dry run capability close to the method.

=head1 PARAMETERS

=head2 dry_it (CODE)

This method export to UNIVERSAL one parameter called dry_it, and it works with MooseX::Role::DryRunnable

=head1 SEE ALSO

L<Moose::Role>, L<Attribute::Handlers>, L<MooseX::Role::DryRunnable>.

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