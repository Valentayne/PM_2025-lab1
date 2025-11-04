resource "google_compute_network" "backside-network" {
  project                 = "my-project-name"
  name                    = "backside-network"
  auto_create_subnetworks = false
  mtu                     = 1460
  routing_mode= REGIONAL
}

resource "google_compute_network" "front-back-network" {
  project                 = "my-project-name"
  name                    = "front-back-network"
  auto_create_subnetworks = false
  mtu                     = 1460
}

module "network" {
  source          = "./modules/network"
  region          = "europe-central2"
}
