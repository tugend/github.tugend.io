---
category: technical 
tags: programming node devops 
layout: post--technical
title: "Azure Pipelines"
published: false
---

The purpose of this project was to get acquainted with Azure Pipelines. To do
so, I registered a free account on Azure and got to work. I'm pretty happy with
the experience though it feels like there's a lot more left to learn. =)

In the following I'll introduce a bit of the important basic terminology, and
then dig into what I think is the important pros and cons of using Azure as an
infrastructure for your pipeline. Finally I'll share some of the technical
issues I had trouble with.

### Technical Summary

To state it briefly, I made a website in typescript, and set up an Azure Build
and Release pipeline to build, test and deploy the output in a QA and Prod
environment. I used a Azure Git Repo, TestCafe, Typescript, Mustache and TS-Node
et. al to build it. 

For comparison I also setup a GitHub Repo and setup a Github Build Pipeline that
could also trigger an Azure Release Pipeline.

### Terminology
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

Azure has both '*build pipelines*' and '*release pipelines*' and in a sane world
those would have clearly disjunct purposes. In Azure they are sadly not. It
seems there's a prevalent opinion that release pipelines should be considered
obsolete and avoided since build pipeline can do both build and deploys.

In my opinion this is a python 2.x+3.x kinda cluster fuck, and I absolutely hate
it. Let's dig down! =)

### Build Pipelines

A build pipeline is defined in a yaml file and stored in the source file
repository itself but can reference template yaml files from other repositories.

It seems to me that the industry is moving towards a preference for
self-contained and explicit configurations which has the advantages of being
very visible, easy to both read and share, and can be maintained in the same
version control as everything else.

Here's how a build pipeline looks in Azure. Here I have three stages, build and
test, deploy to QA and deploy PROD. Each entry in the deploy overview correspond
to a 'run' of the pipeline.

![Build Pipeline Deploy
Overview](/assets/azure-pipelines/build-pipelines--deploy-overview.png "Build
Pipeline Deploy Overview")

We can dig further into a specific pipeline run and see the different 'stages'
of the pipeline, and are also allowed to rerun selected stages.

![Build Pipeline Single Deploy
View](/assets/azure-pipelines/build-pipelines--deploy-view.png "Build Pipeline
Single Deploy View")

Build pipelines do NOT offer proper support for managing and viewing deploys,
but they do actually support deploys as part of the pipeline. I'll get back to
why this is an issue a little bit later.

```yaml
## My Build Pipeline Definition

variables:
  build-time: $[ format('{0:yyyy}:{0:MM}:{0:dd}', pipeline.startTime) ]
  isMain: $[eq(variables['Build.SourceBranch'], 'refs/heads/master')] ## TODO: This is a bit hacky. Probably much better to use to pipelines instead?

trigger:
  branches:
    include:
      - master

pool:
  vmImage: ubuntu-latest

stages:
  - stage: "Build"
    displayName: "Build"
    jobs: 
    - job: "Build"
      displayName: "Build And Test"
      steps:
        - task: NodeTool@0
          displayName: 'Install Node'
          inputs: 
            versionSpec: '18.x'

        - script: npm install
          displayName: 'Node Install'

        - script: >
            npm run build  --
            stage=QA
            output=output/qa
            build-time=$(build-time)
            build=$(Build.BuildNumber)
            message="$(Build.SourceVersionMessage)"
            version=$(Build.SourceVersion)
          displayName: 'Node QA Build'   

        - script: >
            npm run build  --
            stage=PROD
            output=output/prod
            build-time=$(build-time)
            build=$(Build.BuildNumber)
            message="$(Build.SourceVersionMessage)"
            version=$(Build.SourceVersion)
          displayName: 'Node Prod Build'   

        - script: npm run unit:test
          displayName: 'Node Tests'

        - script: npm run percy:test
          displayName: 'Run e2e tests'

        - task: PublishBuildArtifacts@1
          condition: and(succeeded(), eq(variables.isMain, 'true'))
          displayName: 'Build artifacts for QA'
          inputs:
            PathtoPublish: 'output/qa'
            ArtifactName: 'qa-artifact'
            publishLocation: 'Container'

        - task: PublishBuildArtifacts@1
          condition: and(succeeded(), eq(variables.isMain, 'true'))
          displayName: 'Build artifacts for Prod'
          inputs:
            PathtoPublish: 'output/prod'
            ArtifactName: 'prod-artifact'
            publishLocation: 'Container'

  ## ---------------------------------------------------------------------------#
  ## Include only this part if you want to deploy as part of the build pipeline #
  ## ---------------------------------------------------------------------------#
  - stage: "Deploy_QA"
      displayName: "Deploy to QA"
      dependsOn: "Build"
      condition: and(succeeded(), eq(variables.isMain, 'true'))
      jobs: 
      - deployment: "Copy_Files"
        displayName: "Copy Files to QA"
        environment: "AzureGettingStarted--QA"
        strategy:
        runOnce:
          deploy:
            steps:
            - task: AzureFileCopy@4
              displayName: "Copy files"
              inputs:
                SourcePath: '$(Pipeline.Workspace)\qa-artifact\*'
                azureSubscription: 'Visual Studio Premium med MSDN (422db7ec-3d3b-4796-a31d-d7ab8d6f5824)'
                Destination: 'AzureBlob'
                storage: 'azgettstdstoraccname'
                ContainerName: '$web'
                BlobPrefix: 'qa'

    - stage: "Deploy_Prod"
      displayName: "Deploy to Prod"
      condition: and(succeeded(), eq(variables.isMain, 'true'))
      dependsOn: "Deploy_QA"
      jobs: 
      - deployment: "Copy_Files"
        displayName: "Copy Files to Prod"
        environment: "AzureGettingStarted--Prod"
        strategy:
        runOnce:
          deploy:
            steps:
            - task: AzureFileCopy@4
              displayName: "Copy files"
              inputs:
                SourcePath: '$(Pipeline.Workspace)\prod-artifact\*'
                azureSubscription: 'Visual Studio Premium med MSDN (422db7ec-3d3b-4796-a31d-d7ab8d6f5824)'
                Destination: 'AzureBlob'
                storage: 'azgettstdstoraccname'
                ContainerName: '$web'
                BlobPrefix: 'prod'                          
```


### Release Pipelines

A release pipeline is configured using an online input based editor that
consists of a lot of small custom wizards, and the underlying configuration file
is a 500+ line generated and difficult to read boilerplate yaml file.

Version control is solely supported as a cloud based custom 'history' of
changes, and the configuration cannot be stored locally or easily exported.

It is possible to reuse templates across pipelines though, and there's a
reasonably practical built-in guidance to guide you along too.

Because of the way configuration is handled online, this is by many considered a
legacy variant of pipelines that's supposed to be replaced by a similar
configuration paradigm as is used for build pipelines (TODO: check if there's
any references to these claims).

![Release Pipeline
Configuration](/assets/azure-pipelines/release-pipeline--stage-definition.png
"Release Pipeline Configuration")

![Release Pipeline Configuration
History](/assets/azure-pipelines/release-pipeline--diff-example.png "Release
Pipeline Configuration History")

What release pipelines get right though, is the very informative and easy to use
overview of deploys distinctly decoupled the build of what is deployed. It also
invites cleanly separating build and deploy which seems very prudent to me,
you'd want to be able to deploy exactly the same code version again and you want
to avoid wasting time doing unnecessary builds - something that you otherwise
very easy end up doing if you want to force deploys into the build pipeline
instead.

![Release Pipeline Deploy
Management](/assets/azure-pipelines/release-pipeline--release-management.png
"Release Pipeline Deploy Management")

```yaml
# Extract from Release Pipeline
# Deploy to QA step yaml definition

steps:
- task: AzureFileCopy@4
  displayName: 'Deploy to QA'
  inputs:
    SourcePath: '$(System.DefaultWorkingDirectory)/_azure-getting-started/qa-artifact/*'
    azureSubscription: 'Visual Studio Premium med MSDN (422db7ec-3d3b-4796-a31d-d7ab8d6f5824)'
    Destination: AzureBlob
    storage: azgettstdstoraccname
    ContainerName: '$web'
    BlobPrefix: qa
```

### Why build pipelines deploy management is funky

As mentioned, I've often come across developers who wants to shoehorn everything
into the build pipelines because that's simpler than having to use both build
and release pipelines. Superficially build pipelines also seems to support
deploy management just fine. So what's the issue?

Let me be specific.

If I want to redeploy using a build pipeline, something that in my experience is
very common due to many different reasons such as errors, platform issues,
debugging ect.. In that case I have two options. Either I start a new run of the
pipeline, or I access an existing run and select 'rerun' a stage. A new run
starts automatically when I merge to master.

In the example below I did a bit of both in the following order.

1) 20220927.25: Push of commit c312af85 automatically produced a deploy to QA
   and Prod.
2) 20220927.26: Push of commit b53d8419 automatically produced a deploy to  QA
   and Prod.

3) 20221009.4: I manually started a new pipeline for b53d8419 but misconfigured
   the run resulting in a failure. This could easily happen if I wanted to do a
   redeploy after e.g. a server change.
4) 20221009.6: I figured out what was wrong and did another manual pipeline run
   of b53d8419, this time with success all the way to QA, but since is already
   in prod, there was no reason to risk a redundant redeploy.

5) After finding that c312af8f was broken in QA and I was getting really tired
   of the unordered mess of new pipeline runs, I instead went back to run
   20220927.26 and just reran the QA stage.

The end state is that b53d8419 is deployed in Prod and c312af85 is deployed in
QA with a template that may have produced a different actual behavior than the
previous deploy. Notice that the second run from the bottom does not look like
it's deployed to prod, but that because reruns whites-out the following sections
if you rerun. Bullet (1) and (2) is normal behavior, (3) and (4) illustrates
that doing new runs in a different order than the commits may quickly cause an
ambiguous mess and (5) illustrates that rerunning one or more stages in an
existing pipeline run results in a loss of information in the overview.

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
have to accept that for each re-deploy you'll have to do a new and often
completely redundant run of the  build and test stages before the pipeline gets
to the deploy. 

Now imagine a company where deploys are slow easily taking between 8-30 minutes,
and where redeploy and temporary rollbacks are common. =(

### Conclusion

I'd recommend for all but the most trivial cases, to use the build pipeline to
build, and the release pipeline to deploy. The view of the build pipeline is
clearly intended to show a set of stages in the process of producing a build
output, in which case it makes sense that the order of the runs doesn't matter
and that any 'reruns' is expected to complete all stages again. 

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
be better options out there. I'd also really, really prefer to have a local way
of verifying the pipeline configuration worked - I don't like the dependency of
testing changes in the cloud, onr do I appreciate the frustratingly slow
feedback loop there often is when doing pipeline changes in Azure - because you
can't test it out on a local machine.

That being said, I don't have too much insight into other CI/CD systems, so I
might just be expecting too much, and I'll even admit there's a lot of help in
both the community, the docs, and the built in intellisense, they do try to help
you figure it out. So it's not all bad.

### PercyJs and e2e tests

Out of interest, I tried to add visual regression testing to the pipeline. What
a hassle. My main problem was that the test site I had built included platform
dependent emoticons and the scripts I wrote for screenshot capturing kept being
off depending on which machine I took them on. So not really something that
would work as an integral part in a team-based development pipeline.

Then I tried to wrap everything in a Docker container, which quickly became very
slow and tedious to setup and configure in the pipeline, was frustrating to
debug, and still didn't handle my hope of also including Safari based browsers.
I should also add creating a Docker file that includes multiple browsers, node
and emoticons quickly becomes rather ugly - maybe I missed something?

Then I discovered visual regression testing as a service; Browserstacks newly
acquired Percy.io. What they do is to support a plugin that hooks easily into
your existing e2e tests and adds support for taking DOM snapshots. The 'as a
service' part comes into play when the plugin automatically upload the snapshots
to their service and renders a screenshot in Safari, Firefox, Edge, Chrome, etc.
Very nice!

Finally you can hook up the pipeline to require manual approval for any
difference between the previous screenshots and the current, if they differ and
you need approval you click the integrated link and can see a nicely rendered
visual diff highlighting the difference. 

I cannot emphasis enough, how much this could have made my life easier in the
past. I'm very excited about this! Did I mention that it's free for the first
2.000 screenshots per year? =)

It integrated out of the box with a few clicks with my GitHub project, but sadly
I never figured out how to setup the right authorizations to allow access to my
azure repository - something which I find very difficult to figure out. =/

![Percy.IO](/assets/azure-pipelines/percy-example.png "Percy.IO")

### Frecking slow and frustrating, pipelines really need to be FAST

In general, I must say working with a cloud based pipeline such as Azure can be
a bit frustrating. Regardless of how you optimize it, it remains slow resulting
in a distractingly slow feedback. I would really appreciate being able to just
test the pipeline on my local computer and then upload the code after the fact -
but alas, it seems I \*must\* maintain the pipeline configuration in the cloud
only. =/

### Sources

#### Code
* [Sample Website QA |
windows.net](https://azgettstdstoraccname.z13.web.core.windows.net/qa/index.html)
* [Sample Website Prod |
windows.net](https://azgettstdstoraccname.z13.web.core.windows.net/prod/index.html)
* [Code | GitHub](https://github.com/tugend/azure-getting-started) * [Pipeline |
dev.azure.com](https://dev.azure.com/tugend0180/azure-getting-started/_git/azure-getting-started)

#### Articles
* [What is Azure Pipelines |
learn.microsoft.com](https://learn.microsoft.com/en-us/azure/devops/pipelines/get-started/what-is-azure-pipelines?view=azure-devops)
* [Key Concepts in Azure Devops |
learn.microsoft.com](https://learn.microsoft.com/en-us/azure/devops/pipelines/get-started/key-pipelines-concepts?view=azure-devops)
* [How to break a single command inside a `script` step on multiple lines |
stackoverflow](https://stackoverflow.com/questions/59198459/how-to-break-a-single-command-inside-a-script-step-on-multiple-lines)
* [Debugging subscription+principal issue in Azure |
brettmckenzie.net](https://brettmckenzie.net/2020/03/23/azure-pipelines-copy-files-task-authentication-failed/)
* [Azure Portal for managing subscriptions |
portal.azure.com](https://portal.azure.com) * [Azure Devops Portal for pipeline
and repo | dev.azure.com](https://dev.azure.com/tugend0180) * [Azure Container
Content (requires login) |
portal.azure.com](https://portal.azure.com/#view/Microsoft_Azure_Storage/ContainerMenuBlade/~/overview/storageAccountId/%2Fsubscriptions%2F422db7ec-3d3b-4796-a31d-d7ab8d6f5824%2Fresourcegroups%2Fazure-getting-started-resource-group%2Fproviders%2FMicrosoft.Storage%2FstorageAccounts%2Fazgettstdstoraccname/path/%24web)
* [Separate build and release pipelines |
blog.bitsrc.io](https://blog.bitsrc.io/separating-build-and-release-pipelines-for-effective-devops-2b0ad5b74af1)
* [What is CI/CD | wikipedia](https://en.wikipedia.org/wiki/CI/CD) * [PercyIO |
percy.io](https://percy.io/) * [Running node tests in Docker |
docs.docker](https://docs.docker.com/language/nodejs/run-tests/) * [Running
testcafe node tests in Docker |
testcafe.io](https://testcafe.io/documentation/402838/guides/advanced-guides/use-testcafe-docker-image)