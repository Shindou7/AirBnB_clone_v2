include stdlib

# Update package lists
exec { 'Update lists':
    command => '/usr/bin/apt update',
}

# Install Nginx
package { 'nginx':
    ensure  => 'present',
    require => Exec['Update lists'],
}

# Create directory tree
exec { 'Create Directory Tree':
    command => '/bin/mkdir -p /data/web_static/releases/test /data/web_static/shared',
    require => Package['nginx'],
}

# HTML content
$head = "  <head>\n  </head>"
$body = "  <body>\n    Holberton School\n  </body>"
$index = "<html>\n${head}\n${body}\n</html>\n"

# Create Fake HTML
file { 'Create Fake HTML':
    ensure  => 'present',
    path    => '/data/web_static/releases/test/index.html',
    content => $index,
    require => Exec['Create Directory Tree'],
}

# Create Symbolic Link
file { 'Create Symbolic Link':
    ensure  => 'link',
    path    => '/data/web_static/current',
    force   => true,
    target  => '/data/web_static/releases/test',
    require => File['Create Fake HTML'],
}

# Set permissions
exec { 'Set permissions':
    command => '/bin/chown -R ubuntu:ubuntu /data',
    require => File['Create Symbolic Link'],
}

# Nginx service
service { 'nginx':
    ensure  => 'running',
    enable  => true,
    require => Package['nginx'],
}

# Nginx configuration
$loc_header='location /hbnb_static/ {'
$loc_content='alias /data/web_static/current/;'
$new_location="\n\t${loc_header}\n\t\t${loc_content}\n\t}\n"

file_line { 'Set Nginx Location':
    ensure  => 'present',
    path    => '/etc/nginx/sites-available/default',
    after   => 'server_name _;',
    line    => $new_location,
    notify  => Service['nginx'],
    require => Exec['Set permissions'],
}
