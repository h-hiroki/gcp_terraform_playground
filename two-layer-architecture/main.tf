# インスタンスグループが利用する仮想マシンのテンプレート。
# このテンプレを元にインスタンスを複数作成していけまっせ。
resource "google_compute_instance_template" "default" {
  name_prefix = "default-"
  machine_type = "f1-micro"

  disk {
    source_image = "debian-cloud/debian-9"
  }

  network_interface {
    network = "default"
  }
}
