# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = "${var.hcloud_token}"
}

data "template_file" "cloud_init" {
  template = "${file("${path.module}/templates/init.yml")}"

  vars = {
    user_name = "${var.user_name}"
  }
}

data "template_file" "floating_ip" {
  template = "${file("${path.module}/templates/floating_ip_conf")}"

  vars = {
    floating_ip = "${var.floating_ip_address}"
  }
}

data "template_file" "install_env" {
  template = "${file("${path.module}/templates/install-env.sh")}"

  vars = {
    devenv = "${var.devenv}"
  }
}

data "template_file" "install_tools" {
  template = "${file("${path.module}/templates/install-tools.sh")}"

  vars = {
    git_user   = "${var.git_user}"
    git_editor = "${var.git_editor}"
    git_mail   = "${var.git_mail}"
    volume_id  = "${var.projects_volume_id}"
  }
}

data "template_file" "zshrc" {
  template = "${file("${path.module}/templates/.zshrc")}"

  vars = {
    user_name = "${var.user_name}"
  }
}

data "hcloud_floating_ip" "devgate-ip" {
  ip_address = "${var.floating_ip_address}"
}

data "hcloud_volume" "repos" {
  id = "${var.projects_volume_id}"
}

# Create a server
resource "hcloud_server" "devgate" {
  name        = "devgate"
  image       = "ubuntu-18.04"
  server_type = "${var.server_type}"
  location    = "${var.location}"
  ssh_keys    = "${var.ssh_keys}"

  labels = {
    "devenv"      = "${var.devenv}"
    "floating_ip" = "${var.floating_ip_address}"
    "volume"      = "${var.projects_volume_id}"
    "user_name"   = "${var.user_name}"
  }

  user_data = "${data.template_file.cloud_init.rendered}"

  provisioner "file" {
    connection {
      host        = "${hcloud_server.devgate.ipv4_address}"
      agent       = false
      private_key = "${file("${var.ssh_key_path}")}"
    }

    source      = "${path.module}/.ssh"
    destination = "/home/${var.user_name}/.ssh"
  }

  provisioner "file" {
    connection {
      host        = "${hcloud_server.devgate.ipv4_address}"
      agent       = false
      private_key = "${file("${var.ssh_key_path}")}"
    }

    content     = "${data.template_file.floating_ip.rendered}"
    destination = "/etc/network/interfaces.d/60-${var.floating_ip_address}.cfg"
  }

  provisioner "file" {
    connection {
      host        = "${hcloud_server.devgate.ipv4_address}"
      agent       = false
      private_key = "${file("${var.ssh_key_path}")}"
    }

    content     = "${data.template_file.install_env.rendered}"
    destination = "/home/${var.user_name}/install-env.sh"
  }

  provisioner "file" {
    connection {
      host        = "${hcloud_server.devgate.ipv4_address}"
      agent       = false
      private_key = "${file("${var.ssh_key_path}")}"
    }

    content     = "${data.template_file.install_tools.rendered}"
    destination = "/home/${var.user_name}/install-tools.sh"
  }

  provisioner "file" {
    connection {
      host        = "${hcloud_server.devgate.ipv4_address}"
      agent       = false
      private_key = "${file("${var.ssh_key_path}")}"
    }

    content     = "${data.template_file.zshrc.rendered}"
    destination = "/home/${var.user_name}/.zshrc"
  }
}

resource "hcloud_floating_ip_assignment" "main" {
  floating_ip_id = "${data.hcloud_floating_ip.devgate-ip.id}"
  server_id      = "${hcloud_server.devgate.id}"
}

resource "hcloud_volume_attachment" "main" {
  volume_id = "${data.hcloud_volume.repos.id}"
  server_id = "${hcloud_server.devgate.id}"
  automount = true
}
