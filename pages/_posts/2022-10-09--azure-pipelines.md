---
category: technical 
tags: programming node devops 
layout: post--technical
title: "Azure Pipelines"
published: false
---

The purpose of this project was to get acquainted with Azure Pipelines. To do so, I registered a free account on Azure and got to work. =)

<!-- ## Road map

* Define what a pipeline is and what the most important criteria for a good one is.

* Write a simple webpage that can be used as a sample project with compilation, unit-test, end2end test and environment dependant deploy.

* Create an Azure Release Pipeline for the sample project.

* Create an Azure Build Pipeline for the sample project 

* Compare the two solutions

* Discuss how well Azure works in general, pros and cons.

* Include a section detailing any technical details.

* Conclusion

* Sources

* Code -->

## What is a devops pipeline?

In my own words, a devops pipeline is the infrastructure that connects the
development effort with the production environment. A good pipeline is one that
makes the journey from the developer machine to production easy, fast and safe thus allowing for fast development cycles(*#Agile*).

As such, a well maintained and well adjusted pipeline is perhaps one the
important pillars of a productive development process.

Assuming an agile work flow and Git version control, let's try to break down what a good pipeline should support.

### Criteria of a good devops pipeline

* Fast; No way around it, fast is better. A short feedback loop allow bugs to be
  fixed faster, the developer can keep focus, and the customer can get new
  content quicker.

* Resilient; The pipeline, should of course, be stabile and work as expected.
  There should for example not be a risk of race conditions if two developers
  try to merge to master at the same time.

* Safe; To avoid errors in production, the pipeline should be
  used to enforce that the code compiles, the tests run and all static code
  quality analyses are satisfied before merging to master. The pipeline should
  protect both the production environment as well as the shared main branch.

* Flexible; A good pipeline should allow easy and fast redeploys and rollback in
  case of problematic errors that's discovered late. 

* Informative; The pipeline should clearly indicate all relevant information
  such as current version deployed per environment, whether a build or deploy is
  currently ongoing, and in case a build or deploy fails, what went wrong.

  When any code branch is pushed or at least a when a pull request is created,
  the pipeline should automatically verify whether all criteria for a merge to
  master is satisfied, thus allowing the developer to get the fast feedback.
  **Such a check should NOT be based on the branch alone, but on the branch
  merged with newest master.**

* The pipeline should preferably be extensible and easy to manage, the more of a
  spaghetti of custom scripts that only one employee can work with, the worse
  it's going to get over time. In case of many teams and pipelines it might also
  be important that a cross team effort can easily add new merge criteria such
  as adding toggle that allow management to enforce a company wide deploy freeze
  during a critical time.

> ### Terminology
>
> * **CI/CD**: Stands for Continuous Integration and Continuous Delivery
> 
> * **Continuous Integration**: Means to 'integrate' small, cohesive units of code
>   changes to the central repository often.
> 
>   In practice, this could mean that each developer daily merge tiny
>   independent updates to master rather than weekly or monthly merge major
>   batches of changes which usually results in difficult implicit and explicit
>   merge conflicts and much slower releases, hence the 'continuous' part.
> 
> * **Continuous Delivery**: Is the second part of the process where any changes to
>   master if automatically, or at least very easily and often deployed to
>   production.


## Pipelines

Azure supports both 'build pipelines' and 'release pipelines', they can be used in conjunction or in competition, are configured in different ways and supports different view. The literature is very confusing on the topic but the general consensus since a year or so back seems to be that release pipelines are a leftover legacy bit that's not completely replaced yet.

In my opinion this is a python 2.x+3.x kinda cluster fuck, and I absolutely hate it. Let's dig down! =)

True for either, is that the configurations are difficult to figure out (even though there's intellisense), because most tasks can be configured using different tools and in different ways. 

I don't like it, it should be much simpler to do trivial and common tasks without massive amounts of copy paste and googling, a good solution should be common and easier than the alternative. 

Instead the configuration files are difficult to debug, relatively easy to kinda make work, but difficult to make work in the right way. 

For example I copy files using 'AzureFileCopy@4' which is currently only supported for windows. That means if I change my vm image to ubuntu instead my deploy just fails with an unhelpful error message and I have to google some forums to understand that I should use do copy the files in a completely different way.

Should I use a different version, is there a different tool that supports ubuntu, it seems a lot of people revert to copying via hacked together cli commands instead or end up feeling forced to use windows.

Just use windows then, well turns out I had the same opposite issue with a different tool that required me to use ubuntu. 

```
##[error]The current operating system is not capable of running this task. That typically means the task was written for Windows only. For example, written for Windows Desktop PowerShell.
```

Alas that's the trend, the tool just doesn't seem that well put together or finished and it doesn't seem to really be moving towards maturity with a reasonably speed either.



### Build Pipelines

A build pipeline is defined in a yaml file that's contained in the repository itself but can reference template yaml files from another repository. The general move in the industry seems to be self-contained configuration which has the advantages of being very visible, easy to read and share, and to maintain in version control with everything else.

Here's how a build pipeline looks. In this case I have three stages, build and test, deploy to a test environment and deploy to a prod environment. Each entry in the deploy overview correspond to a 'run' of the pipeline.

![Build Pipeline Deploy Overview](/assets/azure-pipelines/build-pipelines--deploy-overview.png "Build Pipeline Deploy Overview")

![Build Pipeline Single Deploy View](/assets/azure-pipelines/build-pipelines--deploy-view.png "Build Pipeline Single Deploy View")

My main problem with the build pipelines is the support for managing and viewing deploys. It's frankly an annoying mess. The reason why it's a mess is probably because you're supposed to use the build pipelines to produce reusable packaged builds and then the release pipelines to manage actual deploys or 'releases'.

A lot of people online seems to want to shoehorn everything into the build pipelines because that way they don't have to use both configuration systems - which to be fair just feels a bit awkward.

Superficially it also seems to support deploy management just fine. So what's the issue?

### Why build pipelines deploy management is funky

If I want to redeploy, something that in my experience is very common due to many different reasons such as errors, platform issues, debugging ect.. In that case I have two options if I'm only using a build pipeline. Either I start a new run of the pipeline, or I access an existing run and select 'rerun' a stage. A new run starts automatically when I merge to master.

In the example below I did a bit of both in the following order.

1) Deployed c312af85 to QA and Prod (all green)
2) Deployed b53d8419 to QA and Prod (all green)
3) Tried to deploy b53d8419 again but it failed because I broke the pipeline template. 
4) Fixed the template definition and automatically a new pipeline was run for b53d8419 which deployed to QA again.
5) Deployed c312af85 to QA
6) Manually reran the build and QA stage of the first run of b53d8419.

The end state is that b53d8419 is deployed in Prod and c312af85 is deployed in QA with a template that may have produced a different actual behavior than the previous deploy. Notice that the second run from the bottom does not look like it's deployed to prod, but that because reruns whites-out the following sections if you rerun.

![Raining in Osaka](/assets/azure-pipelines/build-pipelines--bonanza-2.png "Raining in Osaka")

What a mess!

It's very easy to loose track of the current state of the environments, and it's not difficult (I did not manage to figure it out) to find a way to deploy the exact same build to prod twice if the template has change in between, you'll have to dig into history, change the pipeline back, and then do a new full build-deploy. You also end up having to do a complicated bit of extra custom wiring, or just have to accept that for each deploy you'll have to do a new and often completely redundant run of the  build and test stages before the pipeline gets to the deploy. 

BUT to be fair, that's why connected to why it's called a 'build pipeline'. The view is clearly intended to show a set of stages in the process of producing a build output, in which case it makes sense that the order of the runs doesn't matter and that any 'reruns' is expected to complete all stages again. 

A successful build pipeline with the view that's supported should simply produce a unique build artifact that's retained and available for a decoupled release. Sadly that's just now how most use it nor what it kinda leads users to do.


### Release Pipelines

A pipeline is configured using an online input based editor and the underlying configuration file is a 500+ line big and difficult to read boilerplate mess. They do support cloud based version control, but since the config is generated from a lot of small wizards it's not terrible helpful. The configuration cannot be stored locally or in a version control system you control.

I understand many may feel this is frustrating but to be fair, I think it can be argued that not only should the build and deploys be cleanly decoupled but it's often a separate team that's responsible for how deploys are executed, where as it makes more sense that the repository owning team manage the pipeline configuration for building and testing.

And yes, it is possible to reuse and manage deployment configurations across repositories.

But just look at the final view for releases, this is much easier to work with. Gives a non-ambigious and practical overview of deploys and you're able to deploy the exact same code twice without wasting time on a new build and test stage.

![Build Pipeline Configuration](/assets/azure-pipelines/release-pipeline--release-management.png "Build Pipeline Configuration")

![Build Pipeline Configuration History](/assets/azure-pipelines/release-pipeline--diff-example.png "Build Pipeline Configuration History")

![Raining in Osaka](/assets/azure-pipelines/release-pipeline--stage-definition.png "Raining in Osaka")

### Conclusion

Personally, I think the configurations in azure and how everything is hooked up to subscriptions, and access rights is terrible and needlessly complex and difficult to figure out. Way to much is kinda hidden away and results in a trial and error approach to making your pipeline work. In my opinion it should be easy to do right and difficult to do wrong, same as with programming with any other framework.

That being said, I don't have too much insight into other systems and cloud based pipelines is generally complex anyway you look at it. I will admit there's a lot of help in both the community, the docs, and the built in intellisense, they do try to help you figure it out.

In closing, I really, really, think everybody using azure pipelines in a professional capacity ought to use build AND release pipelines as the current set up is due to the deploy management and overview of build pipelines compared to release pipelines.

## Technical Learnings

### PercyJs and e2e tests
### Go through notes
### Frecking slow and frustrating, pipelines really need to be FAST
### Containers sucks

### Sources

#### Code
* [code@github](https://github.com/tugend/azure-getting-started)
* [pipeline@dev.azure.com](https://dev.azure.com/tugend0180/azure-getting-started/_git/azure-getting-started)

#### Articles
* [what-is-azure-pipelines@learn.microsoft](https://learn.microsoft.com/en-us/azure/devops/pipelines/get-started/what-is-azure-pipelines?view=azure-devops)
* [ci/cd@wikipedia](https://en.wikipedia.org/wiki/CI/CD)



https://blog.bitsrc.io/separating-build-and-release-pipelines-for-effective-devops-2b0ad5b74af1







https://help.talend.com/r/en-US/Cloud/software-dev-lifecycle-best-practices-guide/going-further-configuring-azure-pipeline-to-only-build-artifacts-that-have-changed