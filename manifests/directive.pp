#directive.pp

define sudo::directive (
  $ensure  = present,
  $content = '',
  $source  = ''
) {

  # sudo skipping file names that contain a "."
  $dname = regsubst($name, '\.', '-', 'G')

  file {"/etc/sudoers.d/${dname}":
      ensure  => $ensure,
      owner   => root,
      group   => root,
      mode    => '0440',
      content => $content ? {
        ''      => undef,
        default => "#puppet\n${content}\n",
      },
      source  => $source ? {
        ''      => undef,
        default => $source,
      },
      notify => $ensure ? {
        'present' => Exec["sudo-syntax-check for file ${dname}"],
        default   => undef,
      },
      require => Package['sudo'],
  }

  exec {"sudo-syntax-check for file ${dname}":
    command     => "visudo -c -f '/etc/sudoers.d/${dname}' || ( rm -f '/etc/sudoers.d/${dname}' && exit 1)",
    refreshonly => true,
  }

}
