resource "yandex_compute_instance" "vm" {
  count = "${length(var.hostnames)}"
  name = "vm-${count.index}"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  hostname = "${var.hostnames[count.index]}"

  resources {
    core_fraction = 20 # Гарантированная доля vCPU
    cores  = 2
    memory = 2
  }

  placement_policy {
    placement_group_id = "${yandex_compute_placement_group.group1.id}"
  }

  boot_disk {
    initialize_params {
      image_id = "${var.image_id}"
      type = "network-ssd"
      size = "15"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }
  
  metadata = {
    user-data = "${file("metadata.yaml")}"
  }

  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_compute_placement_group" "group1" {
  name = "test-pg1"
}
#------------network----------------
resource "yandex_vpc_network" "network-1" {
  name = "network-1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet-1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}
#---------snapshot-------------------
resource "yandex_compute_snapshot" "snapshot-1" {
  count = "${length(var.hostnames)}"
  name           = "disk-snapshot-${count.index}"
  source_disk_id = "${yandex_compute_instance.vm[count.index].boot_disk[0].disk_id}"
}

#---------balancer-------------------
resource "yandex_lb_network_load_balancer" "lb-1" {
  name = "lb-1"
  listener {
    name = "my-lb1"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  attached_target_group {
    target_group_id = yandex_lb_target_group.test-1.id
    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}

#---------target-group------------------
resource "yandex_lb_target_group" "test-1" {
  name      = "test-1"
  target {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    address   = yandex_compute_instance.vm[0].network_interface.0.ip_address
  }
  target {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    address   = yandex_compute_instance.vm[1].network_interface.0.ip_address
  }
}

#--------output------------------
output "internal_ip_address_vm" {
  value = yandex_compute_instance.vm[*].network_interface.0.ip_address
  description = "The IP address"
}

output "external_ip_address_vm" {
  value = yandex_compute_instance.vm[*].network_interface.0.nat_ip_address
}

output "lb_ip_address" {
# value = tolist(yandex_lb_network_load_balancer.lb-1.listener[*].external_address_spec).*
#  value = yandex_lb_network_load_balancer.lb-1.network_interface[0].ipv4_address 
#  value = yandex_lb_network_load_balancer.lb-1.listener[*].external_address_spec.*

value = yandex_lb_network_load_balancer.lb-1.listener[*].external_address_spec.*

#  value = var.load_balancing_enabled ? yandex_lb_network_load_balancer.lb-1.0.ip : ""

}
