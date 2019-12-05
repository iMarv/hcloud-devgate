# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}

# Get template for userdata and fill user name
data "template_file" "cloud_init" {
  template = file("${path.module}/templates/init.yml")

  vars = {
    user_name = var.user_name
  }
}

# Get template for configuration of floating IP and update it according to the selected ip
data "template_file" "floating_ip" {
  template = file("${path.module}/templates/floating_ip_conf")

  vars = {
    floating_ip = var.floating_ip_address
  }
}

# Get template for environment install step and fill devenv variable
data "template_file" "install_env" {
  template = file("${path.module}/templates/install-env.sh")

  vars = {
    devenv = var.devenv
  }
}

# Get template for tooling install step
data "template_file" "install_tools" {
  template = file("${path.module}/templates/install-tools.sh")

  vars = {
    git_user   = var.git_user
    git_editor = var.git_editor
    git_mail   = var.git_mail
    volume_id  = var.projects_volume_id
  }
}

# Get template for zshrc and fill relevant parts of config
data "template_file" "zshrc" {
  template = file("${path.module}/templates/.zshrc")

  vars = {
    user_name = var.user_name
  }
}

data "hcloud_floating_ip" "devgate-ip" {
  ip_address = var.floating_ip_address
}

data "hcloud_volume" "repos" {
  id = var.projects_volume_id
}

# Create a server
resource "hcloud_server" "devgate" {
  name        = "devgate"
  image       = "ubuntu-18.04"
  server_type = var.server_type
  location    = var.location
  ssh_keys    = var.ssh_keys

  # The labels are not used by this template but can provide a better overview
  # when searching for resources in your hetzner cloud project
  labels = {
    "devenv"      = var.devenv
    "floating_ip" = var.floating_ip_address
    "volume"      = var.projects_volume_id
    "user_name"   = var.user_name
    "git_user"    = replace(var.git_user, " ", "_")
    "git_mail"    = replace(var.git_mail, "@", "_at_")
    "git_editor"  = var.git_editor
  }

  user_data = data.template_file.cloud_init.rendered

  # Copies `.ssh` folder from this repository into the home directory of the desired
  # user on the remote machine.
  provisioner "file" {
    connection {
      type        = "ssh"
      host        = hcloud_server.devgate.ipv4_address
      agent       = false
      private_key = file(var.ssh_key_path)
    }

    source      = "${path.module}/.ssh"
    destination = "/home/${var.user_name}/.ssh"
  }

  # Writes the configuration that is required for our floating ip into the
  # according directory
  provisioner "file" {
    connection {
      type        = "ssh"
      host        = hcloud_server.devgate.ipv4_address
      agent       = false
      private_key = file(var.ssh_key_path)
    }

    content     = data.template_file.floating_ip.rendered
    destination = "/etc/network/interfaces.d/60-${var.floating_ip_address}.cfg"
  }

  # Writes environment install script to remote server
  provisioner "file" {
    connection {
      type        = "ssh"
      host        = hcloud_server.devgate.ipv4_address
      agent       = false
      private_key = file(var.ssh_key_path)
    }

    content     = data.template_file.install_env.rendered
    destination = "/home/${var.user_name}/install-env.sh"
  }

  # Writes tooling install script to remote server
  provisioner "file" {
    connection {
      type        = "ssh"
      host        = hcloud_server.devgate.ipv4_address
      agent       = false
      private_key = file(var.ssh_key_path)
    }

    content     = data.template_file.install_tools.rendered
    destination = "/home/${var.user_name}/install-tools.sh"
  }

  # Writes zshrc to remote server
  provisioner "file" {
    connection {
      type        = "ssh"
      host        = hcloud_server.devgate.ipv4_address
      agent       = false
      private_key = file(var.ssh_key_path)
    }

    content     = data.template_file.zshrc.rendered
    destination = "/home/${var.user_name}/.zshrc"
  }
}

resource "hcloud_floating_ip_assignment" "main" {
  floating_ip_id = data.hcloud_floating_ip.devgate-ip.id
  server_id      = hcloud_server.devgate.id
}

resource "hcloud_volume_attachment" "main" {
  volume_id = data.hcloud_volume.repos.id
  server_id = hcloud_server.devgate.id
  automount = true
}

