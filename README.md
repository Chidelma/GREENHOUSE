# AWS Practical Interview

## Intro
Welcome to our AWS Practical Interview. This interview tests core AWS concepts such as EKS knowledge, networking and permissions, as well as soft skills such as troubleshooting and collaboration. We want it to be collaborative and to be be close to our actual jobs - so just think of it as a day on our team!

## Getting Started

You should have already received instructions on what tools we'll be using for this interview. If you were unable to install these tools please let us know during the interview.

Here's a list of the tools you should already have installed:

```text
awscli     2+
helm       3
kubectl    1.29+
terraform  1.7.4 # see .terraform-version if using tf-env
```

At the start of the interview, you should:

* Share your desktop via Zoom
* `git clone` this repo to your workstation

> [!TIP]
> Auth problems? Try `gh auth login --web` and cloning via HTTPS

Follow the instructions received in Zoom chat to:

* Login to the AWS console UI
* Export your temporary AWS credentials to a local terminal tab
* Setup access to the interview EKS cluster

## Instructions
### Schedule

We will roughly follow this interview schedule:

- 0-5 minutes: Intros / Instructions
- 5-55 minutes: Exercise
- 55-60 minutes: Questions

### Problem Statement

Our goal today is get an app working called puppy-pics. It is a simple web application that runs on EKS and displays puppy pictures on your browser. The pictures on stored on AWS S3, and the application generates a [presigned URL](https://docs.aws.amazon.com/AmazonS3/latest/userguide/using-presigned-url.html) for the image requested. Unfortunately, this application does not work! Help us find what out what's wrong and apply your fixes.

By the end of the interview, you should hopefully be able to visit the application on your browser and view some puppy pictures. It is up to you to find the correct host to visit, but the following paths should work:

```
/puppies
/puppies/puppy1.jpg
/puppies/puppy2.jpg
/puppies/puppy3.jpg
```

This is a highly collaborative exercise, so feel free to ask us questions, to brainstorm ideas with your interviewer and/or to use Google for help.

You also have the following at your disposal for debugging, diagnosing, and testing solutions:

* _this Git repo_. Feel free to explore and modify the code in here.
* _the AWS console_. It is totally fine to test solutions here out of band, but we would prefer if you showed us how you might approach this via infrastructure as code.
* _terraform_. The current (remote) state is up to date with the code, and you should feel free to do any plans or applies as you see fit.
* _kubectl_. You'll need this configured properly to access the cluster.
* _helm_. Feel free to use the helm CLI if needed.

Please share your screen while you work. 

Good luck!
