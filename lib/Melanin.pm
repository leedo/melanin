package Melanin;

use Carp;
use IPC::Open3;
use Symbol 'gensym'; 

sub new {
  my ($class, $target, %args) = @_;

  bless {
    target => $target,
    bin    => $args{bin}    ||"/usr/bin/pygmentize",
    lexer  => $args{lexer}  || "text",
    format => $args{format} || "html",
  }, $class;
}

sub execute {
  my $self = shift;

  my($wtr, $rdr, $err);
  $err = gensym; #ugh

  my $pid = open3($wtr, $rdr, $err, $self->command);
  print $wtr $self->{target};
  close $wtr;
  waitpid($pid, 0);

  local $/;
  my $err = <$err>;
  my $out = <$rdr>;

  croak $err if $err;
  $out =~ s{</pre></div>\Z}{</pre>\n</div>};
  return $out;
}

sub command {
  my $self = shift;
  return (
    $self->{bin},
    '-l', $self->{lexer},
    '-f', $self->{format},
  );
}

1;
