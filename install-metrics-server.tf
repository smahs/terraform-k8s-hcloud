resource "null_resource" "metrics-server" {
  connection {
    host        = hcloud_server.master.0.ipv4_address
    type        = "ssh"
    private_key = file(var.ssh_private_key)
  }

  provisioner "file" {
    source      = "scripts/metrics-server.sh"
    destination = "/root/metrics-server.sh"
  }

  provisioner "remote-exec" {
    inline = ["/bin/bash /root/metrics-server.sh"]
  }

  depends_on = [null_resource.flannel]
}
