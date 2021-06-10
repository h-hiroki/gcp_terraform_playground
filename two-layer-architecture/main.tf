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

# インスタンステンプレートを利用してリソース作成する。
resource "google_compute_region_instance_group_manager" "default" {
  name = "default"
  region = "asia-northeast1"
  version {
    instance_template = google_compute_instance_template.default.self_link # テンプレートを利用する
  }

  base_instance_name = "mig"
  target_size = 2

  auto_healing_policies {
    health_check = google_compute_health_check.mig_health_check.self_link
    initial_delay_sec = 30
  }

  timeouts {
    // 変更後に10から15分程度かかる時もあるので設定している
    create = "15m"
  }
}

# オートスケール設定
resource "google_compute_region_autoscaler" "default" {
  name = "default"
  target = google_compute_region_instance_group_manager.default.self_link # instance_group_managerに対して設定する

  autoscaling_policy {
    max_replicas = 5
    min_replicas = 2
  }
}

# ヘルスチェックリクエスト。80番ポート利用
resource "google_compute_health_check" "mig_health_check" {
  name = "default"

  http_health_check {
    port = 80
  }
}

# ヘルスチェック用の80番ポート利用許可
resource "google_compute_firewall" "mig_health_check" {
  name = "health-check"
  network = "default"
  
  allow {
    protocol = "tcp"
    ports = [80]
  }

  source_ranges = [ "130.211.0.0/22", "35.191.0.0./16" ]
}

# 22ポート利用許可
resource "google_compute_firewall" "default_ssh" {
  name = "default-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports = [22]
  }
  source_ranges = [ "0.0.0.0/0" ]
  target_tags = [ "allow-ssh" ]
}