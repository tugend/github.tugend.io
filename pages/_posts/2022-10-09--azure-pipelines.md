---
category: technical 
tags: programming node devops 
layout: post--technical
title: "Azure Pipelines"
published: false
---

The purpose of this project was to get acquainted with Azure Pipelines. To do
so, I registered a free account on Azure and got to work. I'm pretty happy with
the experience. =)

In the following I'll introduce a bit of the important basic terminology, and
then dig into what I think is the important pros and cons of using Azure as an
infrastructure for your pipeline. Finally I'll share some of the technical
issues I had trouble with.

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

## Introduction

### What is a devops pipeline?

In my own words, a devops pipeline is the infrastructure that connects the
development effort with a production environment. A good pipeline is one that
makes the journey from the developer machine to production easy, fast and safe
thus allowing for fast development cycles(*#Agile*, **#CI/CD**).

As such, a well maintained and well adjusted pipeline is one the important
pillars of a productive development process.

Assuming an agile work flow and Git version control, let's try to break down
what a good pipeline should support.

> ### Terminology
>
> * **CI/CD**: Stands for Continuous Integration and Continuous Delivery
> 
> * **Continuous Integration**: Means to 'integrate' small, cohesive units of
>   code changes to the central repository often.
> 
>   In practice, this could mean that each developer daily merge tiny
>   independent updates to master rather than weekly or monthly merge major
>   batches of changes which usually results in difficult implicit and explicit
>   merge conflicts and much slower releases, hence the 'continuous' part.
> 
> * **Continuous Delivery**: Is the second part of the process where any changes
>   to master if automatically, or at least very easily and often deployed to
>   production.

### What is a good devops pipeline

* **Fast**; No way around it, fast is better. A short feedback loop allow bugs
  to be fixed faster, the developer can keep focus, and the customer can get new
  content quicker - wait time is expensive.

* **Robust**; The pipeline should stabile and easy to maintain, same as for any
  other high use critical infrastructure. Breakdowns is expensive.

  To be robust, the pipeline should preferably be extensible and easy to manage,
  the more of a spaghetti of custom scripts that only one employee can work
  with, the worse it's going to get over time. In case of many teams and
  pipelines it might also be important that a cross team effort can easily add
  new merge criteria such as adding toggle that allow management to enforce a
  company wide deploy freeze during a critical time.

* **Safe**; To avoid runtime errors, the pipeline should be used to enforce that
  the code compiles, tests run and all static code quality checks are satisfied
  before merging to master. The pipeline should protect both the production
  environment as well as the shared main branch.

* **Flexible**; A good pipeline should allow easy and fast redeploys and
  rollback in case of runtime errors. 

* **Informative**; The pipeline must clearly indicate relevant information such
  as current version deployed per environment, whether a build or deploy is
  currently ongoing, and in case a build or deploy fails, what went wrong.

  When a code branch is pushed or at least a when a pull request is created, the
  pipeline should not only automatically verify whether all criteria for a merge
  to master is satisfied but clearly indicate what is wrong if those criteria is
  not satisfied -thus allowing the developer to get the fast feedback. *Such a
  check should NOT be based on the branch alone, but on the branch merged with
  newest master.*


## The confusion of the dual pipeline setup

Azure has both '*build pipelines*' and '*release pipelines*' and in a sane world those would have clearly disjunct purposes. In Azure they are sadly not. It seems there's a prevalent opinion that release pipelines should be considered obsolete and avoided since build pipeline can do both build and deploys.

In my opinion this is a python 2.x+3.x kinda cluster fuck, and I absolutely hate
it. Let's dig down! =)

### Build Pipelines

A build pipeline is defined in a yaml file and stored in the source file
repository itself but can reference template yaml files from other repositories.

It seems to me that the industry is moving towards a preference for self-contained and explicit configurations which has the advantages of being very visible, easy to both read and share, and can be maintained in the same version control as everything else.

Here's how a build pipeline looks. In this case I have three stages, build and
test, deploy to a test environment QA and deploy to a prod environment Prod.
Each entry in the deploy overview correspond to a 'run' of the pipeline.

![Build Pipeline Deploy
Overview](/assets/azure-pipelines/build-pipelines--deploy-overview.png "Build
Pipeline Deploy Overview")

We can dig further into a specific pipeline run and see the different 'stages' of the pipeline, and are also allowed to rerun selected stages.

![Build Pipeline Single Deploy
View](/assets/azure-pipelines/build-pipelines--deploy-view.png "Build Pipeline
Single Deploy View")

Build pipelines do NOT offer proper support for  managing and viewing deploys,
but they do actually support deploys as part of the pipeline. I'll get back to
why this is an issue a little bit later.


### Release Pipelines

A release pipeline is configured using an online input based editor that
consists of a lot of small custom wizards, and the underlying configuration file
is a 500+ line generated and difficult to read boilerplate yaml file.

Version control is solely supported as a cloud based custom 'history' of changes, and the configuration cannot be stored locally or easily exported.

It is possible to reuse templates across pipelines though, and there's a reasonably practical built-in guidance to guide you along too.

Because of the way configuration is handled online, this is by many considered a legacy variant of pipelines that's supposed to be replaced by a similar configuration paradigm as is used for build pipelines (TODO: check if there's any references to these claims).

![Release Pipeline Configuration](/assets/azure-pipelines/release-pipeline--stage-definition.png "Release Pipeline Configuration")

![Release Pipeline Configuration History](/assets/azure-pipelines/release-pipeline--diff-example.png "Release Pipeline Configuration History")

What release pipelines get right though, is the very informative and easy to use overview of deploys distinctly decoupled the build of what is deployed. It also invites cleanly separating build and deploy which seems very prudent to me, you'd want to be able to deploy exactly the same code version again and you want to avoid wasting time doing unnecessary builds - something that you otherwise very easy end up doing if you want to force deploys into the build pipeline instead.

![Release Pipeline
Deploy Management](/assets/azure-pipelines/release-pipeline--release-management.png
"Release Pipeline Deploy Management")

### Why build pipelines deploy management is funky

As mentioned, I've often come across developers who wants to shoehorn everything
into the build pipelines because that's simpler than having to use both build and release pipelines. Superficially build pipelines also seems to support deploy management just fine. So what's the issue?

Let me be specific.

If I want to redeploy using a build pipeline, something that in my experience is
very common due to many different reasons such as errors, platform issues,
debugging ect.. In that case I have two options. Either I start a new run of the
pipeline, or I access an existing run and select 'rerun' a stage. A new run
starts automatically when I merge to master.

In the example below I did a bit of both in the following order.

1) 20220927.25: Push of commit c312af85 automatically produced a deploy to QA and Prod.
2) 20220927.26: Push of commit b53d8419 automatically produced a deploy to  QA and Prod.

3) 20221009.4: I manually started a new pipeline for b53d8419 but misconfigured the run resulting in a failure. This could easily happen if I wanted to do a redeploy after e.g. a server change.
4) 20221009.6: I figured out what was wrong and did another manual pipeline run of b53d8419, this time with success all the way to QA, but since is already in prod, there was no reason to risk a redundant redeploy.

5) After finding that c312af8f was broken in QA and I was getting really tired of the unordered mess of new pipeline runs, I instead went back to run 20220927.26 and just reran the QA stage.

The end state is that b53d8419 is deployed in Prod and c312af85 is deployed in
QA with a template that may have produced a different actual behavior than the
previous deploy. Notice that the second run from the bottom does not look like
it's deployed to prod, but that because reruns whites-out the following sections
if you rerun. Bullet (1) and (2) is normal behavior, (3) and (4) illustrates that doing new runs in a different order than the commits may quickly cause an ambiguous mess and (5) illustrates that rerunning one or more stages in an existing pipeline run results in a loss of information in the overview.

![Build Pipeline Bonanza](/assets/azure-pipelines/build-pipelines--bonanza-2.png
"Build Pipeline Bonanza")

What a mess! To summarize, there's not good way unless you always do pretty
sequential deploys to your environments. In all other cases, it's easy to loose
track of the current state of your environments. 

Further more it's non-trivial to deploy the exact same build to prod twice if
the template has changed in between, you'll have to dig into history, change the
pipeline back, and then do a new full build-deploy. (At least as far as I have
managed to figure out).

Finally, you'll either have to do a complicated bit of extra custom wiring, or
have to accept that for each re-deploy you'll have to do a new and often completely
redundant run of the  build and test stages before the pipeline gets to the
deploy. 

Now imagine a company where deploys are slow easily taking between 8-30 minutes, and where redeploy and temporary rollbacks are common. =(

### Conclusion

I'd recommend for all but the most trivial cases, to use the build
pipeline to build, and the release pipeline to deploy. The view of the build
pipeline is clearly intended to show a set of stages in the process of producing
a build output, in which case it makes sense that the order of the runs doesn't
matter and that any 'reruns' is expected to complete all stages again. 

A successful build pipeline with the view that's supported should simply produce
a unique build artifact that's retained and available for a decoupled release.
Sadly that's just now how most use it nor what it kinda leads users to do.

## Technical Learnings

### Personal opinion 

I think the configurations in Azure with a seemingly endless different ways of
doing the same thing, different tool versions, tools that only work on windows
and tools that only work on ubuntu, and how everything is hooked up to
subscriptions, and access rights is terrible and needlessly complex and
difficult to work with. There is way to much hidden away and you'll often end up
doing a trial and error approach to making your pipeline work. 

In my opinion it should be easy to do right and difficult to do wrong, same as
with programming with any other framework. If that's not the case, there should
be better options out there. I'd also really, really prefer to have a local way of verifying the pipeline configuration worked - I don't like the dependency of testing changes in the cloud, onr do I appreciate the frustratingly slow feedback loop there often is when doing pipeline changes in Azure - because you can't test it out on a local machine.

That being said, I don't have too much insight into other CI/CD systems, so I
might just be expecting too much, and I'll even admit there's a lot of help in
both the community, the docs, and the built in intellisense, they do try to help
you figure it out. So it's not all bad.

### PercyJs and e2e tests
### Go through notes
### Frecking slow and frustrating, pipelines really need to be FAST
### Containers sucks
****
### Sources

#### Code
* [code@github](https://github.com/tugend/azure-getting-started)
* [pipeline@dev.azure.com](https://dev.azure.com/tugend0180/azure-getting-started/_git/azure-getting-started)

#### Articles
* [what-is-azure-pipelines@learn.microsoft](https://learn.microsoft.com/en-us/azure/devops/pipelines/get-started/what-is-azure-pipelines?view=azure-devops)
* [ci/cd@wikipedia](https://en.wikipedia.org/wiki/CI/CD)



https://blog.bitsrc.io/separating-build-and-release-pipelines-for-effective-devops-2b0ad5b74af1







https://help.talend.com/r/en-US/Cloud/software-dev-lifecycle-best-practices-guide/going-further-configuring-azure-pipeline-to-only-build-artifacts-that-have-changed




True for either, is that the configurations are difficult to figure out (even
though there's intellisense), because most tasks can be configured using
different tools and in different ways. 

I don't like it, it should be much simpler to do trivial and common tasks
without massive amounts of copy paste and googling, a good solution should be
common and easier than the alternative. 

Instead the configuration files are difficult to debug, relatively easy to kinda
make work, but difficult to make work in the right way. 

For example I copy files using 'AzureFileCopy@4' which is currently only
supported for windows. That means if I change my vm image to ubuntu instead my
deploy just fails with an unhelpful error message and I have to google some
forums to understand that I should use do copy the files in a completely
different way.

Should I use a different version, is there a different tool that supports
ubuntu, it seems a lot of people revert to copying via hacked together cli
commands instead or end up feeling forced to use windows.

Just use windows then, well turns out I had the same opposite issue with a
different tool that required me to use ubuntu. 

```
##[error]The current operating system is not capable of running this task. That typically means the task was written for Windows only. For example, written for Windows Desktop PowerShell.
```

Alas that's the trend, the tool just doesn't seem that well put together or
finished and it doesn't seem to really be moving towards maturity with a
reasonably speed either.