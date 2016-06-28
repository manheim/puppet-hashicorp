define man_hashicorp::tool(
  $tool    = $title,
  $version = undef,
  $ext     = 'zip',
  $bin_dir = '/usr/bin',
  $tmp_dir = '/tmp',
) {

  include stdlib
  include archive

  case $::osfamily {
    'RedHat', 'Debian', 'Suse': {
      $_osfamily = 'linux'
    }
    'Darwin': {
      $_osfamily = 'darwin'
    }
    'OpenBSD': {
      $_osfamily = 'openbsd'
    }
    'FreeBSD': {
      $_osfamily = 'freebsd'
    }
    'Solaris': {
      $_osfamily = 'solaris'
    }
  }

  case $::architecture {
    'x86_64': {
      $_arch = 'amd64'
    }
    'i386', 'x86': {
      $_arch = '386'
    }
    default: {
      $_arch = $::architecture
    }
  }

  $supported_tool_names = [
    '^consul-template$',
    '^terraform$',
  ]

  validate_re("${tool}", $supported_tool_names, "The provided tool (${tool}) is not currently supported.")
  validate_re("${version}", '^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}(?:-rc[0-9]{1,2})?', "The provided version (${version}) is not valid.")
  validate_absolute_path("${bin_dir}") 

  $release_url = 'https://releases.hashicorp.com'
  $tool_url    = "${release_url}/${tool}"
  $version_url = "${tool_url}/${version}"
  $os_url      = "${version_url}/${tool}_${version}_${_osfamily}_${_arch}.${ext}"

  ensure_packages(['unzip', 'wget'], {'ensure' => 'present'})

  archive { "install ${tool}":
    provider     => 'wget',
    path         => "${tmp_dir}/${tool}.${ext}",
    extract_path => $bin_dir,
    source       => $os_url,
    extract      => true,
    cleanup      => true,
    require      => Package['unzip', 'wget'],
  }
}
