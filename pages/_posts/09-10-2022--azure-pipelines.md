---
category: technical 
tags: programming node devops 
layout: post--technical
title: "Azure Pipelines"
published: false
---

The purpose of this project was to get acquainted with Azure Pipelines. I'd like to have reached all my sub goals, I have learned enough shut this down without any regrets.

## Road map

* Define what a pipeline is and what the most important criteria for a good one is.

* Write a simple webpage that can be used as a sample project with compilation, unit-test, end2end test and environment dependant deploy.

* Create an Azure Release Pipeline for the sample project.

* Create an Azure Build Pipeline for the sample project 

* Compare the two solutions

* Discuss how well Azure works in general, pros and cons.

* Include a section detailing any technical details.

* Conclusion

* Sources

* Code

## What is a devops pipeline?

In my own words, a devops pipeline is the necessary infrastructure to connect the development effort with the production environment. A good pipeline is one that make the journey from the developer machine to production easy, fast and safe. As such a well maintained and well adjusted pipeline is perhaps one of the most important pillars of a productive development process.

Let's try to break down what a good pipeline should support. I'll assume that the pipeline will be hooked up to a version control of some kind (git). The buzz words that cover the following are 'Continous Integration'

### Criteria of a good devops pipeline

* Fast; No way around it, fast is better. A short feedback loop allow bugs to be fixed faster, the developer can better keep focus, and the customer can get new content quicker.

* Resilient; The pipeline, should of course, be stabile and consistently working as expected. There should for example not be race conditions if two developers try to merge to master at the same time.

* Safe; A good way to help avoid errors in production, the pipeline can be used to enforce that all code compiles, all tests run and all static code quality analysis if any green light the changes before merging to master. The pipeline should protect both the production environment as well as any shared master branches between developers.
(this is also called 'Continuous Integration')

* Flexible; A good pipeline should allow easy and fast redeploy and rollback in case of problematic deploys. 

* Informative; The pipeline should clearly indicate all relevant information such as current version deployed per environment, whether a build or deploy is current ongoing, and in case a build or deploy fails, what went wrong.

Further more, when a pull request is created the pipeline should automatically verify whether all criteria for a merge to master is satisfied allowing the developer to get the fast feedback. **Such a check should NOT be based on the branch alone, but on the branch merged with newest master.**

* Staged; Although a lot can be automated the pipeline should still support enforced approvals, for example such that any deploy to prod must require a manual approval. Deploying the code changes in different environment from test to prod should be automated (this is also called Continuous Delivery)

* The pipeline should preferably be extensible and easy to manage, the more of a spaghetti of custom scripts that only one employee can work with, the worse it's going to get over time. In case of many teams and pipelines it might also be important that a cross team effort can easily add new criteria such as adding toggle that allow management to enforce a company wide deploy freeze during a critical time.


## Pipelines
### Azure Release Pipelines
### Azure Build Pipelines
### Comparison
### Azure Pipelines in general
### Conclusion
## Technical Learnings
## Sources



### Sources

#### Code
* [code@github](https://github.com/tugend/azure-getting-started)
* [pipeline@dev.azure.com](https://dev.azure.com/tugend0180/azure-getting-started/_git/azure-getting-started)

#### Articles
* [what-is-azure-pipelines@learn.microsoft](https://learn.microsoft.com/en-us/azure/devops/pipelines/get-started/what-is-azure-pipelines?view=azure-devops)