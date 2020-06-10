provider "ibm" {
  generation = 2
  region     = "us-south"
}

data "ibm_resource_group" "rg" {
  name = "Default"
}

resource "ibm_is_vpc" "test_schematics_demo_vpc" {
  depends_on     = [data.ibm_resource_group.rg]
  name           = "test-schematics-demo-vpc"
  resource_group = data.ibm_resource_group.rg.id
}

resource "ibm_resource_instance" "test_schematics_demo_pdns" {
  depends_on        = [ibm_is_vpc.test_schematics_demo_vpc]
  name              = "test-schematics-demo-pdns"
  resource_group_id = data.ibm_resource_group.rg.id
  location          = "global"
  service           = "dns-svcs"
  plan              = "standard-dns"
}

resource "ibm_dns_zone" "test_schematics_demo_pdns_zone" {
  depends_on  = [ibm_resource_instance.test_schematics_demo_pdns]
  name        = "test.com"
  instance_id = ibm_resource_instance.test-pdns-instance.guid
  description = "testdescription"
  label       = "testlabel"
}

resource "ibm_dns_permitted_network" "test_schematics_demo_pdns_permitted_network" {
  depends_on  = [ibm_dns_zone.test_schematics_demo_pdns_zone]
  instance_id = ibm_resource_instance.test-pdns-instance.guid
  zone_id     = ibm_dns_zone.test-pdns-zone.zone_id
  vpc_crn     = ibm_is_vpc.test_pdns_vpc.resource_crn
}

resource "ibm_dns_resource_record" "test_schematics_demo_pdns_record_a" {
  depends_on  = [ibm_dns_permitted_network.test_schematics_demo_pdns_permitted_network]
  instance_id = ibm_resource_instance.test-pdns-instance.guid
  zone_id     = ibm_dns_zone.test-pdns-zone.zone_id
  type        = "A"
  name        = "testA"
  rdata       = "1.2.3.5"
  ttl         = 900
}
