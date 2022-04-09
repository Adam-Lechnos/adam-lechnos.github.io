---
title: "PCI Compliance in AWS - Simplified (featured in ISC2 Blog)"
date: 2019-09-01 12:00:00 -0000
categories: grc
---

## PCI Compliance in AWS - Simplified

**This blog post also featured in the [(ISC)² Blog](https://blog.isc2.org/isc2_blog/2019/10/pci-compliance-in-aws-simplified.html)**

Payment Card Industry Data Security Standards or PCI DSS, are a set of 12 requirements with over 300 controls which apply to any organization which stores, processes or transmits credit card data. Today, I will attempt to add some clarity around PCI compliance within AWS.

Concepts and practices were sourced from the referenced document below and here I will break it down further. I do suggest you first read the Architecting for PCI DSS Scoping and Segmentation on AWS and come back to enhance your understanding of the methods being applied and its rationale.

For a quick primer on PCI-DSS, please refer to the council's overview PDF.
Referenced from: https://d1.awsstatic.com/whitepapers/pci-dss-scoping-on-aws.pdf


### Infrastructure Services

Infrastructure services such as EC2 require the most amount of effort from a PCI compliance
perspective based on the AWS Shared Responsibility Model.
Other services are categorized as ‘Abstracted’ or ‘Containerized’(not to be confused with containers such as Docker or such services as Fargate thoughencompassed by this category).
Examples are EC2 instances which require host based firewalls, configuration and patch management, OS level logging, and an assurance of non-vendor defaults such as the usage CIS bench-marking (using AWS AMIs should be sufficient).

### Kubernetes on EC2

Like EC2, ECS and EKS are all deemed ‘Infrastructure’ based services. These services expose administrative access and control at the OS layer and hence their designation. Today, since we manually manage Kubernetes in a cluster of EC2 instances, we therefore must apply PCI practices at all layers of the shared responsibility model except for physical controls such as in the examples mentioned above.

#### AWS Fargate Considerations

Using AWS Fargate in lieu of EC2 hosting Kubernetes would reduce the PCI compliance footprint as Fargate is considered a ‘Containerized’ service and hence, the degree of PCI compliance requirements is greatly reduced as per the AWS Shared Responsibility Model.
The instantiation of Fargate within-in it’s own AWS Account and the endpoints it connects would be in scope. Fargate would not require network, OS level, and like EC2, nor physical level controls.

### Abstracted Services

URL Load Balancers, API Gateways, and other ‘Abstracted’ services are services in which the degree of control is limited to the movement of data using AWS APIs. AWS handles network, OS, and physical controls therefore, minimizing PCI scope of work.

The instantiation of an Abstracted service within its own AWS Account and the endpoints it
connects would be in scope. Fargate would not require network or OS level controls and like EC2 nor physical level controls, like Containerized services.

#### Network and Encryption Level Abstracted Services

Application Load Balancers, Web Application Firewalls, and KMS must be configured to terminate TLS version 1.1 or greater between itself and all endpoints.

#### Connected-to and Security-Impacting Gotchas
Any service that supports, directly impacts, or provide security to the CDE fall with-in scope of PCI compliance.
i.e, Vault provides configuration parameters for Docker Containers in Kubernetes within the CDE and hence, the EC2 instance in which Vault sits atop of, would fall with-in scope of PCI compliance.

#### Abstracted Service Caveats

Normally, if Abstracted services such as AWS S3 or Application Load Balancer transmits or stores CHD, these services fall with-in scope of PCI compliance. Since these services are considered ‘Abstracted’, network and OS level controls do not apply. If these services do not handle CHD, segmentation is assumed and therefore out of scope for PCI compliance even if located within the same CDE environment.


### Examples

S3 Bucket without CHD
An S3 bucket with-in the same VPC as the CDE in which no CHD is stored or passes, is not considered part of the CDE.

S3 Bucket with CHD
An S3 bucket containing CHD would fall with-in scope of PCI compliance however, only pertinent PC requirements would apply such as role-based access controls and not OS layer controls such as anti-virus, etc, essentially controls around data access via the S3 APIs.

SQS without CHD
If we were to replace Kafka with AWS SQS, we eliminate the use of Infrastructure services in favor of Abstracted Services, as Kafka currently sits atop EC2, therefore, SQS would be out of scope for PCI compliance unless it processes CHD either though it’s connected to the CDE.

SQS with CHD
If we were to replace Kafka with AWS SQS in which CHD would be stored and transmitted, only those endpoints in which SQS connects would fall with-in scope of PCI even if with-in the same CDE.

### Conclusion
Within the newly created AWS PCI Zone, replacing Kubernetes on EC2 with Fargate and possibly Kafka with SQS, would eliminate many of the PCI requirements in that zone as a result of using only. Abstracted and Containerized services as mentioned in the preceding examples above.
