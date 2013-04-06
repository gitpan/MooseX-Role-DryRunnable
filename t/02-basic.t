use Test::More tests => 2;

subtest "should do nothing if not in dry run mode" => sub {
  plan tests => 1;
  
  {
    package Foo;
    use Moose;
    with 'MooseX::Role::DryRunnable' => { 
      methods => [ qw(bar) ]
    };

    sub bar {
      Test::More::ok(1, "should be called");
    }

    sub is_dry_run { # required !
      0
    }

    sub on_dry_run { # required !
      Test::More::fail("should not be called")
    }

    no Moose;
    1; 
    
    my $foo = Foo->new();
    $foo->bar();
  }
};

subtest "should call on_dry_run if in dry run mode" => sub {
  plan tests => 1;
  
  {
    package Foo2;
    use Moose;
    with 'MooseX::Role::DryRunnable' => { 
      methods => [ qw(bar) ]
    };

    sub bar {
      Test::More::fail("should not be called")
    }

    sub is_dry_run { # required !
      1
    }

    sub on_dry_run { # required !
      Test::More::ok(1, "should be called");
    }

    no Moose;
    1; 
    
    my $foo = Foo2->new();
    $foo->bar();
  }
};