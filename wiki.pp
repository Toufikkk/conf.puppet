class dokuwiki {
  include dokuwiki::params
  include dokuwiki::packages
  include dokuwiki::source
}

class dokuwiki::packages {
  package { 'apache2':
    ensure => present
  }

  package { 'php7.3':
    ensure => present
  }
}

class dokuwiki::source {
  include dokuwiki::params

  file { 'dokuwiki::download':
    ensure => present,
    source => 'https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz',
    path   => "${source_path}/dokuwiki.tgz"
  }

  exec { 'dokuwiki::extract':
    command => 'tar xavf dokuwiki.tgz',
    cwd     => "${source_path}",
    path    => ["${binary_path}"],
    require => File['dokuwiki::download'],
    unless  => "test -d ${source_path}/dokuwiki-2020-07-29"
  }

  file { 'dokuwiki::rename':
    ensure  => present, 
    path    => "${source_path}/dokuwiki",
    require => Exec['dokuwiki::extract']
  }
}

class dokuwiki::params {
  $source_path = '/usr/src'
  $web_path = '/var/www'
  $binary_path = '/usr/bin'
}

define dokuwiki::deploy ($siteName="", $documentRoot="") {
  include dokuwiki::params

  file { "$siteName":
    ensure  => directory,
    source  => "${source_path}/dokuwiki",
    path    => "$documentRoot",
    recurse => true,
    owner   => 'www-data',
    group   => 'www-data',
    require => File['dokuwiki::rename']
  }

  file { "template $siteName":
    ensure  => file,
    path    => "/etc/apache2/sites-enabled/${siteName}.conf",
    content => template("/home/vagrant/tp1/tp-puppet/tpS1E1/default-template.conf")

  }
}

node 'server0' {
  include dokuwiki

  dokuwiki::deploy { "recettes.wiki":
    siteName     => "recettes.wiki",
    documentRoot => "/var/www/recettes.wiki"
  }
  dokuwiki::deploy { "tajineworld.com":
    siteName => "tajineworld.com",
    documentRoot => "/var/www/tajineworld.wiki"
  }
}

node 'server1' {
  include dokuwiki

  dokuwiki::deploy { "politique.wiki":
    siteName => "politique.wiki",
    documentRoot => "/var/www/politique.wiki"
  }
}
