resource "null_resource" "flannel" {
  count = var.flannel_install ? 1 : 0

  connection {
    host        = hcloud_server.master.0.ipv4_address
    private_key = file(var.ssh_private_key)
  }

  provisioner "remote-exec" {
    inline = ["kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"]
  }

  depends_on = [hcloud_server.master]
}
