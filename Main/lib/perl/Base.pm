package OrthoMCLEngine::Main::Base;

use strict;
use FindBin;
use lib "$FindBin::Bin/../lib/perl";
use DBI;
use base 'Exporter';
our @EXPORT = qw(startBuiltInMysql stopBuiltInMysql);

sub new {
  my ($class, $configFile, $loghandle) = @_;

  my $self = {};
  bless($self,$class);
  $self->parseConfigFile($configFile, $loghandle);
  return $self;
}

sub parseConfigFile {
  my ($self, $configFile, $loghandle) = @_;

  open(F, $configFile) || die "Can't open config file '$configFile'\n";

  $self->{configFile} = $configFile;
  while(<F>) {
    chomp;
    s/\s+$//;
    next if /^\s*$/;
    next if /^\#/;
    /^(\w+)\=(.+)/ || die "illegal line in config file '$_'\n";
    my $key=$1;
    my $val=$2;
    $self->{config}->{$key} = $val;
    if ($loghandle) {
      $val = '********' if $key eq 'dbPassword';
      print $loghandle localtime() . " configuration: $key=$val\n";
    }
  }
}

sub getConfig {
  my ($self, $prop) = @_;
  die "can't find property $prop in config file" unless $self->{config}->{$prop};
  return $self->{config}->{$prop};
}


sub getDbh {
  my ($self) = @_;

  if (!$self->{dbh}) {
    my $dbVendor = $self->getConfig("dbVendor");
    if ($dbVendor eq 'oracle') {
      require DBD::Oracle;
    } elsif ($dbVendor eq 'mysql') {
      require DBD::mysql;
    } else {
      die "config file '$self->{configFile}' has invalid value '$dbVendor' for dbVendor property\n";
    }
    
    my $dbConnectString = ($self->getConfig("dbConnectString") eq 'builtin') ?
        "dbi:mysql:orthomcl:mysql_socket=$FindBin::Bin/../db/tmp/myortho.sock"
        : $self->getConfig("dbConnectString");
        
    $self->{dbh} = DBI->connect($dbConnectString,
				$self->getConfig("dbLogin"),
				$self->getConfig("dbPassword")) or die DBI::errstr;
  }
  return $self->{dbh};
}
1;


sub startBuiltInMysql {
    my ($dbConnectString) = @_;
    return if $dbConnectString ne 'builtin';

    my $BIN_DIR = "$FindBin::Bin";
    my $cmd = "$BIN_DIR/_start_mysql_builtin";
    my $rt = system($cmd);
    die "FAIL: unable to continue due to previous errors. Quitting.\n" if ($rt);
}

sub stopBuiltInMysql {
    my ($dbConnectString) = @_;
    return if $dbConnectString ne 'builtin';

    my $BIN_DIR = "$FindBin::Bin";
    my $cmd = "$BIN_DIR/_stop_mysql_builtin";
    my $rt = system($cmd);
    die "FAIL: unable to continue due to previous errors. Quitting.\n" if ($rt);
}
