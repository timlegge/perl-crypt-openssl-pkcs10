use Config;
use File::Spec;
use Crypt::OpenSSL::Guess qw(openssl_version openssl_inc_paths openssl_lib_paths);

my %args;

my ($major, $minor, $patch) = openssl_version();
print "Installed OpenSSL: $major.$minor.$patch\n";

my $libs = ' -lssl -lcrypto';
if ($Config{osname} eq 'aix') {
  $libs = $libs . ' -lz';
}

$args{INC} =  openssl_inc_paths();
$args{LIBS} = [openssl_lib_paths() . $libs];

my $cc_option_flags;

if ($Config::Config{cc} =~ /gcc/i) {
  $cc_option_flags .= $ENV{AUTHOR_TESTING} ? ' -Wall -Werror' : ' -Wall';
} else {
  $cc_option_flags .= '';
}

if ($Config{gccversion} =~ /llvm/i) {
  if ( $^O eq 'darwin' && (
    $Config{gccversion} =~ /LLVM 1[2-9].\d.[5-9]/ ||
    $Config{gccversion} =~ /LLVM 1[3-9]/ ))
  {
    $cc_option_flags .= ' -Wno-deprecated-declarations -Wno-compound-token-split-by-macro';
  } else {
    $cc_option_flags .= ' -Wno-deprecated-declarations';
  }

  if ($Config{gccversion} =~ /llvm 13/i) {
      $cc_option_flags .= ' -Wno-compound-token-split-by-macro';
  }

  if ($Config{PERL_VERSION} <= 20) {
    $cc_option_flags .= ' -Wno-error=pointer-bool-conversion';
  }
}

if ($Config{myuname} =~ /sunos|solaris/i) {
  $args{OPTIMIZE} = $cc_option_flags;
} elsif ($Config{myuname} =~ /strawberry-{0,1}perl/i) {
  if ($Config{PERL_VERSION} <= 24) {
    $args{LIBS} = [openssl_lib_paths() . ' -leay32'];
  }
} elsif ($Config{myuname} =~ /darwin/ ) {
  $args{LDDLFLAGS} = openssl_lib_paths() . " " . $Config{lddlflags};
} else {
  $args{LDDLFLAGS} = openssl_lib_paths() . " " . $Config{lddlflags};
  $args{OPTIMIZE} = $cc_option_flags;
}
