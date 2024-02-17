---
title: "AWS CDK - Node/Tree Relationship"
date: 2024-02-17 12:00:00 -0000
categories: aws devops
---

## AWS Cloud Development Kit (CDK) - Understanding the Node/Tree Relationship

### Diagram

![AWS Cloud Development Kit Tree/Node Diagram](https://github.com/Adam-Lechnos/diagrams-devops/blob/main/images-exported/Devops-IaC-AWS_CDK_Tree_Node.drawio.png?raw=true)

### Details

* The AWS CDK is a tree/node relationship structure, requiring the initializing of the root node via the `app = new.cdk.App()` object, imported from the `aws-cdk-lib` CDK library. The object inherits the `Stage` object which in turn inherits the `Construct` object.
* Subsequent AWS resources are instantiated `Stack` objects, such as the `bucketStack = new BucketStack(app, 'BucketStack')` instance created, which in turn inherits the `Construct` object.
* Hence, each new instantiation of an AWS resource, is a child of the Construct, which is then added to the root Construct, `app` per the first `scope` argument for each instantiated resource's constructor.
  * i.e., handlerStack = new HandlerStack(`app`, 'HandlerStack', extendedProps..)
* Resouces created inside resources, such as the `new LambdaFunction(this, 'LambdaFunction', FunctionProps)` Lambda functions, contains the first argument `this`, for the `scope` parameter since this is the parent object, **handlerStack**, which inherits a `Construct` object.

