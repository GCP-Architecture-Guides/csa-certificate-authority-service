##  Copyright 2023 Google LLC
##  
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##  
##      https://www.apache.org/licenses/LICENSE-2.0
##  
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.


##  This code creates demo environment for CSA Certificate Authority Service 
##  This demo code is not built for production workload ##




# Enable the necessary API services
resource "google_project_service" "api_service" {
  for_each = toset([
    "privateca.googleapis.com",
    "storage.googleapis.com",
  ])

  service = each.key

  project                    = var.demo_project_id
  disable_on_destroy         = true
  disable_dependent_services = true
  # depends_on = [google_project.demo_project]
}

resource "time_sleep" "wait_enable_service" {
  depends_on       = [google_project_service.api_service]
  create_duration  = "45s"
  destroy_duration = "45s"
}


## Root CA pool
resource "google_privateca_ca_pool" "ca_pool" {
  name     = var.caPoolName
  location = var.network_region
  tier     = var.caTier
  publishing_options {
    publish_ca_cert = true
    publish_crl     = true
  }
  project    = var.demo_project_id
  depends_on = [time_sleep.wait_enable_service]
}



## rootCA 
resource "google_privateca_certificate_authority" "root_ca" {
  location                               = var.network_region
  project                                = var.demo_project_id
  certificate_authority_id               = var.caId
  deletion_protection                    = false # Disable if wish to preserve from being destroyed
  skip_grace_period                      = true
  ignore_active_certificates_on_deletion = true # Disable if wish to save issued certificate when destroyed
  pool                                   = google_privateca_ca_pool.ca_pool.name
  config {
    x509_config {
      ca_options {
        is_ca                  = true
        max_issuer_path_length = 10
      }
      key_usage {
        base_key_usage {
          crl_sign  = true
          cert_sign = true
        }
        extended_key_usage {
          server_auth      = true
          client_auth      = true
          code_signing     = true
          email_protection = false
        }
      }
    }
    subject_config {
      subject {
        organization        = var.subject_organization
        common_name         = var.subject_common_name
        country_code        = var.subject_country_code
        organizational_unit = var.subject_organizational_unit
        province            = var.subject_province
        locality            = var.subject_locality
      }
    }
  }
  key_spec {
    algorithm = var.ca_algo
  }
  lifetime = "315360000s"
  depends_on = [
    google_privateca_ca_pool.ca_pool,
  ]
}


## Sub CA pool Region1
resource "google_privateca_ca_pool" "sub_ca_pool_reg1" {
  name     = var.subcaPoolName
  location = var.network_region
  tier     = var.caTier
  publishing_options {
    publish_ca_cert = true
    publish_crl     = true
  }
  project    = var.demo_project_id
  depends_on = [time_sleep.wait_enable_service]
}


resource "google_privateca_certificate_authority" "sub_ca_reg1" {
  pool                                   = var.subcaPoolName
  project                                = var.demo_project_id
  certificate_authority_id               = var.subCaId
  location                               = var.network_region
  deletion_protection                    = false # Disable if wish to preserve from being destroyed
  skip_grace_period                      = true
  ignore_active_certificates_on_deletion = true # Disable if wish to save issued certificate when destroyed
  subordinate_config {
    certificate_authority = google_privateca_certificate_authority.root_ca.name
  }
  config {
    subject_config {
      subject {
        organization        = var.subject_organization
        common_name         = var.subject_common_name
        country_code        = var.subject_country_code
        organizational_unit = var.subject_organizational_unit
        province            = var.subject_province
        locality            = var.subject_locality
      }
      subject_alt_name {
        dns_names = ["hashicorp.com"]
      }
    }
    x509_config {
      ca_options {
        is_ca = true
        # Force the sub CA to only issue leaf certs
        max_issuer_path_length = 2
      }
      key_usage {
        base_key_usage {
          digital_signature  = true
          content_commitment = true
          key_encipherment   = false
          data_encipherment  = true
          key_agreement      = true
          cert_sign          = true
          crl_sign           = true
          decipher_only      = true
        }
        extended_key_usage {
          server_auth      = true
          client_auth      = true
          code_signing     = true
          email_protection = false
        }
      }
    }
  }
  lifetime = "94608000s"
  key_spec {
    algorithm = var.ca_algo
  }
  type = "SUBORDINATE"
  depends_on = [
    google_privateca_certificate_authority.root_ca,
    google_privateca_ca_pool.sub_ca_pool_reg1,
  ]
}



resource "google_privateca_certificate" "cert_request" {
  pool                  = var.subcaPoolName
  project               = var.demo_project_id
  location              = var.network_region
  certificate_authority = google_privateca_certificate_authority.sub_ca_reg1.certificate_authority_id
  lifetime              = "2592000s"
  name                  = var.cert_name
  pem_csr               = tls_cert_request.demo_leaf_cert.cert_request_pem
}

resource "tls_private_key" "pem_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "demo_leaf_cert" {
  private_key_pem = tls_private_key.pem_key.private_key_pem

  subject {
    common_name  = "demo-example.com"
    organization = "Demo Examples, Inc"
  }
}


resource "null_resource" "certificate_push_gcs" {

  triggers = {
    data_set = "${google_privateca_certificate.cert_request.pem_csr}"
  }

  provisioner "local-exec" {
    command     = <<EOT
      gcloud privateca certificates export ${google_privateca_certificate.cert_request.name} --project ${var.demo_project_id} --issuer-pool ${var.subcaPoolName} --issuer-location ${var.network_region} --include-chain --output-file ${var.demo_project_id}-${google_privateca_certificate.cert_request.name}-chain.crt
      gcloud privateca certificates export ${google_privateca_certificate.cert_request.name} --project ${var.demo_project_id} --issuer-pool ${var.subcaPoolName} --issuer-location ${var.network_region} --output-file ${var.demo_project_id}-${google_privateca_certificate.cert_request.name}.crt
  
  EOT
    working_dir = path.module
  }
  depends_on = [
    google_privateca_certificate_authority.sub_ca_reg1,
    google_privateca_certificate.cert_request,
  ]
}



resource "google_storage_bucket" "certificate_bucket" {
  name                        = "certificate-${var.demo_project_id}"
  location                    = var.network_region
  force_destroy               = true
  project                     = var.demo_project_id
  uniform_bucket_level_access = true
  depends_on                  = [time_sleep.wait_enable_service]
}



# Add certificate file with chain to bucket
resource "google_storage_bucket_object" "certificate_chain_push_gcs" {
  name       = "${var.demo_project_id}-${google_privateca_certificate.cert_request.name}-chain.crt"
  bucket     = google_storage_bucket.certificate_bucket.name
  source     = "${path.module}/${var.demo_project_id}-${google_privateca_certificate.cert_request.name}-chain.crt"
  depends_on = [resource.null_resource.certificate_push_gcs]
}

# Add certificate file without chain to bucket
resource "google_storage_bucket_object" "certificate_push_gcs" {
  name       = "${var.demo_project_id}-${google_privateca_certificate.cert_request.name}.crt"
  bucket     = google_storage_bucket.certificate_bucket.name
  source     = "${path.module}/${var.demo_project_id}-${google_privateca_certificate.cert_request.name}.crt"
  depends_on = [resource.null_resource.certificate_push_gcs]
}




# Deleting the certificate files from local machine
resource "null_resource" "del_local_cert_files" {

  triggers = {
    data_set = "${google_storage_bucket_object.certificate_chain_push_gcs.name}"
  }

  provisioner "local-exec" {
    command     = <<EOT
      rm ${var.demo_project_id}-${google_privateca_certificate.cert_request.name}-chain.crt
      rm ${var.demo_project_id}-${google_privateca_certificate.cert_request.name}.crt
  
  EOT
    working_dir = path.module
  }
  depends_on = [
    google_storage_bucket_object.certificate_chain_push_gcs,
    google_storage_bucket_object.certificate_push_gcs,
  ]
}





## Subordinate CA pool other region
resource "google_privateca_ca_pool" "subca_pool_reg2" {
  name     = var.subcaPoolName2
  location = var.network_region2
  tier     = var.caTier
  publishing_options {
    publish_ca_cert = true
    publish_crl     = true
  }
  project    = var.demo_project_id
  depends_on = [time_sleep.wait_enable_service]
}


resource "google_privateca_certificate_authority" "sub_ca_reg2" {
  pool                                   = var.subcaPoolName2
  project                                = var.demo_project_id
  certificate_authority_id               = var.subCaId2
  location                               = var.network_region2
  deletion_protection                    = false # Disable if wish to preserve from being destroyed
  skip_grace_period                      = true
  ignore_active_certificates_on_deletion = true # Disable if wish to save issued certificate when destroyed
  #  desired_state = "enabled"
  subordinate_config {
    certificate_authority = google_privateca_certificate_authority.root_ca.name
  }
  config {
    subject_config {
      subject {
        organization = "Demo"
        common_name  = "Demo"
      }
      subject_alt_name {
        dns_names = ["demo.com"]
      }
    }
    x509_config {
      ca_options {
        is_ca = true
        # Force the sub CA to only issue leaf certs
        max_issuer_path_length = 2
      }
      key_usage {
        base_key_usage {
          digital_signature  = true
          content_commitment = true
          key_encipherment   = false
          data_encipherment  = true
          key_agreement      = true
          cert_sign          = true
          crl_sign           = true
          decipher_only      = true
        }
        extended_key_usage {
          server_auth      = true
          client_auth      = true
          code_signing     = true
          email_protection = false
        }
      }
    }
  }
  lifetime = "94608000s"
  key_spec {
    algorithm = var.ca_algo
  }
  type = "SUBORDINATE"


  depends_on = [
    google_privateca_certificate_authority.root_ca,
    google_privateca_ca_pool.subca_pool_reg2,
  ]

}
