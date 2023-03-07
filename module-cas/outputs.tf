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




output "_01_cas_project_id" {
  value = var.demo_project_id
}

output "_02_root_ca_name_" {
  value = google_privateca_certificate_authority.root_ca.certificate_authority_id
}


output "_03_sub_ca_name_region1" {
  value = google_privateca_certificate_authority.sub_ca_reg1.certificate_authority_id
}


output "_04_sub_ca_name_region2" {
  value = google_privateca_certificate_authority.sub_ca_reg2.certificate_authority_id
}


output "_05_issued_certificate_name" {
  value = google_privateca_certificate.cert_request.name
}


output "_06_issued_certificate_storage_bucket_name" {
  value = google_storage_bucket.certificate_bucket.name
}

