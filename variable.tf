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



variable "demo_project_id" {
  type        = string
  description = "Project ID to deploy resources"

}


variable "network_region" {
  type        = string
  description = "Primary network region"
  default     = "us-central1"
}

variable "network_region2" {
  type        = string
  description = "Secondary network region"
  default     = "us-east1"
}

variable "ca_algo" {
  type        = string
  description = "Algorithm for the CA certificates"
  default     = "RSA_PKCS1_4096_SHA256"
  # Other option are RSA_PKCS1_2048_SHA256, EC_P256_SHA256,  SIGN_HASH_ALGORITHM_UNSPECIFIED, RSA_PSS_2048_SHA256, RSA_PSS_3072_SHA256, RSA_PSS_4096_SHA256, RSA_PKCS1_3072_SHA256, RSA_PKCS1_4096_SHA256, EC_P256_SHA256, and EC_P384_SHA384
}



variable "caPoolName" {
  type        = string
  description = "CA Pool Name"
  default     = "Demo-Root-Pool"
}

variable "caTier" {
  type        = string
  description = "CA Tier"
  default     = "ENTERPRISE"
}

variable "caId" {
  type        = string
  description = "CA ID"
  default     = "Demo-Root-CA"
}



variable "subject_organization" {
  type        = string
  description = "Organization organization"
  default     = "Demo"

}

variable "subject_common_name" {
  type        = string
  description = "Organization common name"
  default     = "Demo"

}

variable "subject_country_code" {
  type        = string
  description = "Organization country code"
  default     = "US"
}

variable "subject_organizational_unit" {
  type        = string
  description = "Organization organization unit"
  default     = "NA"
}

variable "subject_province" {
  type        = string
  description = "Organization province"
  default     = "NA"
}

variable "subject_locality" {
  type        = string
  description = "Organization locality"
  default     = "NA"
}

variable "subCaId" {
  type        = string
  description = "Organization Sub CA Id"
  default     = "Demo-Sub-CA-Central"
}

variable "caType" {
  type        = string
  description = "Sub CA type"
  default     = "SUBORDINATE" #SELF_SIGNED
}

variable "subcaPoolName" {
  type        = string
  description = "Organization sub ca pool"
  default     = "Demo-Sub-Pool-Central"

}

variable "subCaId2" {
  type        = string
  description = "Organization sub ca id"
  default     = "Demo-Sub-CA-East"

}


variable "subcaPoolName2" {
  type        = string
  description = "Organization sub pool name"
  default     = "Demo-Sub-Pool-East"


}

variable "cert_name" {
  type        = string
  description = "Certificate Name"
  default     = "Demo_Leaf_Cert"


}

