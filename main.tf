provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_ssh_key" "k8s_admin" {
  name       = "k8s_admin"
  public_key = file(var.ssh_public_key)
}

resource "hcloud_server" "master" {
  location    = var.location
  count       = var.master_count
  name        = "master-${count.index + 1}"
  server_type = var.master_type
  image       = var.master_image
  ssh_keys    = [hcloud_ssh_key.k8s_admin.id]

  connection {
    host        = self.ipv4_address
    type        = "ssh"
    private_key = file(var.ssh_private_key)
  }

  provisioner "file" {
    source      = "scripts/bootstrap.sh"
    destination = "/root/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = ["/bin/bash /root/bootstrap.sh"]
  }

  provisioner "file" {
    source      = "scripts/master.sh"
    destination = "/root/master.sh"
  }

  provisioner "remote-exec" {
    inline = ["FEATURE_GATES=${var.feature_gates} /bin/bash /root/master.sh"]
  }

  provisioner "local-exec" {
    command = "/bin/bash scripts/copy-kubeadm-token.sh"

    environment = {
      SSH_PRIVATE_KEY = var.ssh_private_key
      SSH_USERNAME    = "root"
      SSH_HOST        = hcloud_server.master[0].ipv4_address
      TARGET          = "${path.module}/secrets/"
    }
  }
}

resource "hcloud_server" "node" {
  location    = var.location
  count       = var.node_count
  name        = "node-${count.index + 1}"
  server_type = var.node_type
  image       = var.node_image
  depends_on  = [hcloud_server.master]
  ssh_keys    = [hcloud_ssh_key.k8s_admin.id]

  connection {
    host        = self.ipv4_address
    type        = "ssh"
    private_key = file(var.ssh_private_key)
  }

  provisioner "file" {
    source      = "scripts/bootstrap.sh"
    destination = "/root/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = ["/bin/bash /root/bootstrap.sh"]
  }

  provisioner "file" {
    source      = "${path.module}/secrets/kubeadm_join"
    destination = "/tmp/kubeadm_join"

    connection {
      host        = self.ipv4_address
      type        = "ssh"
      user        = "root"
      private_key = file(var.ssh_private_key)
    }
  }

  provisioner "file" {
    source      = "scripts/node.sh"
    destination = "/root/node.sh"
  }

  provisioner "remote-exec" {
    inline = ["/bin/bash /root/node.sh"]
  }
}

