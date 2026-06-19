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


module "module_cas" {
  source                      = "./module-cas"
  demo_project_id             = var.demo_project_id
  network_region              = var.network_region
  network_region2             = var.network_region2
  ca_algo                     = var.ca_algo
  caPoolName                  = var.caPoolName
  caTier                      = var.caTier
  caId                        = var.caId
  subject_organization        = var.subject_organization
  subject_common_name         = var.subject_common_name
  subject_country_code        = var.subject_country_code
  subject_organizational_unit = var.subject_organizational_unit
  subject_province            = var.subject_province
  subject_locality            = var.subject_locality
  subCaId                     = var.subCaId
  caType                      = var.caType
  subcaPoolName               = var.subcaPoolName
  subCaId2                    = var.subCaId2
  subcaPoolName2              = var.subcaPoolName2
  cert_name                   = var.cert_name
}
