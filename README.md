```
This is not an officially supported Google product.
This code creates PoC demo environment for CSA Certificate Authority Service demo. This demo code is not built for production workload. 
```

# Summary

This architecture guide enables a streamlined, secure deployment of [Certificate Authority Service](https://cloud.google.com/certificate-authority-service/docs) (CAS). It creates a root certificate authority along with two subordinate certificate authorities and one leaf certificate. These certificate authorities are highly available, scalable, and simple to maintain, enabling you to build a private Public Key Infrastructure (PKI) to assert identities via certificates and establish a root of trust across your workloads.

While this architecture guide focuses on a full CAS deployment - denoted as architecture 1 in the figure below (i.e., one where all certificate authorities are hosted in Google Cloud) - CAS is extremely flexible and empowers your organization to create a private PKI in a variety of different ways as depicted in the diagram below.

![image](./images/csa-certificat--xg3mmit152b.png)

We'll also provide details on how to use CSR (Certificate Signing Request) to implement Hybrid architecture, in which CAs can reside outside of GCP (architectures #2-3).

# Architecture 

## Design Diagram

![image](./images/csa-certificat--ycmpemoeop.png)

## Product and services

**[Certificate Authority Service (CAS)**](https://cloud.google.com/certificate-authority-service) - Certificate Authority Service is a highly available, scalable Google Cloud service that enables you to simplify, automate, and customize the deployment, management, and security of private certificate authorities (CA).

**[Key Management Service (KMS)**](https://cloud.google.com/security-key-management) - Cloud Key Management Service allows you to create, import, and manage cryptographic keys and perform cryptographic operations in a single centralized cloud service. You can use these keys and perform these operations by using Cloud KMS directly, by using Cloud HSM or Cloud External Key Manager, or by using Customer-Managed Encryption Keys (CMEK) integrations within other Google Cloud services.

**[Google Cloud Storage (GCS)**](https://cloud.google.com/storage) - Cloud Storage is a managed service for storing unstructured data. Store any amount of data and retrieve it as often as you like.

## Design considerations

When designing PKI with GCP CAS, the following limits should be taken into consideration as well as [quotas and limit](https://cloud.google.com/certificate-authority-service/quotas) and [known limitations](https://cloud.google.com/certificate-authority-service/docs/known-limitations):

<table>
  <thead>
    <tr>
      <th><strong>Resource</strong></th>
      <th><strong>Unit</strong></th>
      <th><strong>Value</strong></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Pending CAs1</td>
      <td>per Location per Project</td>
      <td>100</td>
    </tr>
    <tr>
      <td>CAs</td>
      <td>per Location per Project</td>
      <td>1,000</td>
    </tr>
    <tr>
      <td>Unexpired revoked certificates2</td>
      <td>per CA or certificate revocation list (CRL)</td>
      <td>500,000</td>
    </tr>
  </tbody>
</table>

1A pending certificate authority (CA) is a subordinate CA that has been created but not yet activated, and is thus in the AWAITING_USER_ACTIVATION [state](https://cloud.google.com/certificate-authority-service/docs/reference/rest/v1beta1/projects.locations.certificateAuthorities#State).  
2A CRL can contain at most 500,000 unexpired revoked certificates. If you attempt to revoke more than this limit, the revocation request fails. If you need to revoke more than 500,000 certificates, we recommend that you wait until the existing revoked certificates have expired or revoke the issuing CA certificate.



# Deployment

**Terraform Instructions:**

1. Sign in to your organization and assign yourself a **CA Service Admin **and** Cloud KMS Admin** role on the project to be used for the deployment.

1. If a new project needs to be created and enable billing. Follow the steps in [this guide](https://cloud.google.com/resource-manager/docs/creating-managing-projects).

1. Open up Cloud shell and clone the following [git repository](https://github.com/GoogleCloudPlatform/csa-certificate-authority-service) using the command below:

<table>
  <thead>
    <tr>
      <th>git clone https://github.com/GCP-Architecture-Guides/csa-certificate-authority-service.git</th>
    </tr>
  </thead>
  <tbody>
  </tbody>
</table>

1. Navigate to the certificate-authority-service folder.

<table>
  <thead>
    <tr>
      <th>cd csa-certificate-authority-service</th>
    </tr>
  </thead>
  <tbody>
  </tbody>
</table>

1. Export the project id in the Terraform variable

<table>
  <thead>
    <tr>
      <th>export TF_VAR_demo_project_id=[YOUR_PROJECT_ID]</th>
    </tr>
  </thead>
  <tbody>
  </tbody>
</table>

1. While in the certificate-authority-service folder, run the commands below in order. 

<table>
  <thead>
    <tr>
      <th>terraform init</th>
    </tr>
  </thead>
  <tbody>
  </tbody>
</table>

<table>
  <thead>
    <tr>
      <th>terraform plan</th>
    </tr>
  </thead>
  <tbody>
  </tbody>
</table>

<table>
  <thead>
    <tr>
      <th>terraform apply</th>
    </tr>
  </thead>
  <tbody>
  </tbody>
</table>

> if prompted, authorize the API call.

1. Once deployment is finished it will publish the output summary of assets orchestrated. It deploys the resources within five minutes.

![image](./images/csa-certificat--1234.png)

1. After completing the demo, navigate to the certificate-authority-service folder and run the command below to destroy all demo resources.

<table>
  <thead>
    <tr>
      <th>terraform destroy</th>
    </tr>
  </thead>
  <tbody>
  </tbody>
</table>

**Terraform Summary:**

<table>
  <thead>
    <tr>
      <th><strong>Pool</strong></th>
      <th><strong>CA</strong></th>
      <th><strong>Validity</strong></th>
      <th><strong>State</strong></th>
      <th><strong>Subject Name</strong></th>
      <th><strong>Region</strong></th>
      <th><strong>Tier</strong></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><em>Demo-Root-Pool</em></td>
      <td><em>Root CA</em></td>
      <td>10 years</td>
      <td>Enabled</td>
      <td>Organization: <em>Demo</em><br>
<br>
CA CN:<em> Demo</em><br>
<br>
Resource ID: [default]</td>
      <td>us-central1 (Iowa)</td>
      <td>Enterprise</td>
    </tr>
    <tr>
      <td><em>Demo-Sub-Pool</em></td>
      <td><em>Sub CA with Root CA in Google Cloud</em></td>
      <td>3 years</td>
      <td>Enabled</td>
      <td>Organization: <em>Demo</em><br>
<br>
CA CN:<em> Demo</em><br>
<br>
Resource ID: [default]</td>
      <td>us-central1 (Iowa)</td>
      <td>Enterprise</td>
    </tr>
    <tr>
      <td><em>Demo-Sub-Pool-2</em></td>
      <td><em>Sub CA with Root CA in Google Cloud</em></td>
      <td>3 years</td>
      <td>Enabled</td>
      <td>Organization: <em>Demo</em><br>
<br>
CA CN:<em> Demo</em><br>
<br>
Resource ID: [default]</td>
      <td>us-east1</td>
      <td>Enterprise</td>
    </tr>
  </tbody>
</table>

<table>
  <thead>
    <tr>
      <th><strong>Pool</strong></th>
      <th><strong>Accepted CSR Methods</strong></th>
      <th><strong>Allowed Keys & Algorithms</strong></th>
      <th><strong>Key Size & Algorithm</strong></th>
      <th><strong>Publishing Options</strong></th>
      <th><strong>Configured Baseline Values</strong></th>
      <th><strong>Configured Extension Constraints</strong></th>
      <th><strong>Configured Identity Constraints</strong></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><em>Demo-Root-Pool</em></td>
      <td>Allow all</td>
      <td>No restrictions</td>
      <td>RSA_PKCS1_4096_SHA256</td>
      <td>To GCS Bucket in PEM format</td>
      <td>None</td>
      <td>Copy all extensions from certificate requests</td>
      <td>Copy subject and SAN(s) from certificate requests</td>
    </tr>
    <tr>
      <td><em>Demo-Sub-Pool</em></td>
      <td>Allow all</td>
      <td>No restrictions</td>
      <td>RSA_PKCS1_4096_SHA256</td>
      <td>To GCS Bucket in PEM format</td>
      <td>None</td>
      <td>Copy all extensions from certificate requests</td>
      <td>Copy subject and SAN(s) from certificate requests</td>
    </tr>
    <tr>
      <td><em>Demo-Sub-Pool-2</em></td>
      <td>Allow all</td>
      <td>No restrictions</td>
      <td>RSA_PKCS1_4096_SHA256</td>
      <td>To GCS Bucket in PEM format</td>
      <td>None</td>
      <td>Copy all extensions from certificate requests</td>
      <td>Copy subject and SAN(s) from certificate requests</td>
    </tr>
  </tbody>
</table>




# Best Practices

[Best practices for Certificate Authority Service](https://cloud.google.com/certificate-authority-service/docs/best-practices)

# Operations

## Logging And Monitoring

Google Cloud's Certificate Authority Service has several logging and monitoring requirements to ensure the security and integrity of the service. These requirements include the following:

-  Audit logging: Log operations performed on the service, such as certificate issuance, renewal, and revocation, are logged and can be audited by customers.
-  Event notifications: Customers can receive notifications for important events, such as certificate expiration, via email or through a webhook.
-  Certificate transparency: All issued certificates are logged to Transparency logs, which allows audit of issuance and revocation of certificates.
-  Security and availability monitoring: Security and operations teams constantly monitor the service for potential security threats and availability issues.
-  Compliance: Google Cloud's Certificate Authority Service is compliant with various standards which specify security and operational requirements for certificate authorities.

Overall, these logging and monitoring requirements aim to provide customers with transparency and visibility into the service, while also ensuring the security and availability of the service.

## Audit Logging

Google Cloud services write audit logs to help you answer the questions, "Who did what, where, and when?" within your Google Cloud resources.

### Available audit logs

The following types of audit logs are available for CA Service:

-  Admin Activity audit logs   
Includes "admin write" operations that write metadata or configuration information.  
You can't disable Admin Activity audit logs.
-  Data Access audit logs  
Includes "admin read" operations that read metadata or configuration information. Also includes "data read" and "data write" operations that read or write user-provided data.  
To receive Data Access audit logs, you must [explicitly enable](https://cloud.google.com/logging/docs/audit/configure-data-access#config-console-enable) them.
-  For specific audit logs created by the Certificate Authority Service, please refer to (https://cloud.google.com/certificate-authority-service/docs/audit-logging).

## Enable audit logging

Admin Activity audit logs are always enabled; you can't disable them.  
Data Access audit logs are disabled by default and aren't written unless explicitly enabled.  
For information about enabling some or all of your Data Access audit logs, see [Enable Data Access audit logs](https://cloud.google.com/logging/docs/audit/configure-data-access).

## View CAS logs

In the Google Cloud console, you can use the Logs Explorer to retrieve your audit log entries for your Cloud project, folder, or organization:

1. In the Google Cloud console, go to the **Logging> Logs Explorer** page.
1. Select an existing Cloud project, folder, or organization.
1. In the **Query builder** pane, do the following:

```
protoPayload.serviceName="privateca.googleapis.com"
```

## Monitoring Alerting and Reporting

Cloud Monitoring can be used to monitor operations performed on resources in Certificate Authority Service.

### Enabling Recommended Alerts

Use the following instructions to enable recommended alerts.

1. Go to the CA Service Overview page in the Google Cloud console.
1. On the top right of the Overview page, click the **+ 5 Recommended Alerts**.
1. Enable or disable each alert, reading its description.
    -  Some alerts support custom thresholds. For example, you can specify when you want to be alerted for an expiring CA certificate, or the error rate for a high rate of certificate creation failures.
    -  All alerts support [notification channels](https://cloud.google.com/monitoring/support/notification-options).

1. Click **Submit** once you have enabled all desired alerts.

















# CSA Guide
This Cloud Security Architecture uses terraform to setup Certificate Authority Service demo in a project and underlying infrastructure using Google Cloud Services like [Certificate Authority Service](https://cloud.google.com/certificate-authority-service) and [Cloud Storage](https://cloud.google.com/storage).


## CSA Architecture Diagram
The image below describes the architecture of CSA Certificate Authority Service demo.

![Architecture Diagram](./cas-arch.png)



## What resources are created?
Main resources:
- A root certificate authority
- Two sub certificate authorities in different regions
- A certificate from one of the sub certificate authorities



## How to deploy?
The following steps should be executed in Cloud Shell in the Google Cloud Console. 

### 1. Create a project and enable billing
Follow the steps in [this guide](https://cloud.google.com/resource-manager/docs/creating-managing-projects).

### 2. Get the code
Clone this github repository go to the root of the repository.

``` 
git clone https://github.com/googlecloudplatform/csa-certificate-authority-service.git
cd csa-certificate-authority-service
```

### 3. Deploy the infrastructure using Terraform

From the root folder of this repo, run the following commands:

```
export TF_VAR_demo_project_id=[YOUR_PROJECT_ID]
terraform init
terraform apply
```

**Note:** All the other variables are give a default value. If you wish to change, update the corresponding variables in variable.tf file.



## How to clean-up?

From the root folder of this repo, run the following command:
```
terraform destroy
```







