# Puppy Pics

## Overview

Puppy pics is an application that lists and downloads images of puppies from an S3 bucket

## API

### GET /puppies

This endpoint returns a list of puppy pic object keys from the bucket defined in the chart values.

### GET /puppies/<object_key:str>

This endpoint retrieves a puppy pic from the provided object_key within the bucket defined in the chart values.

## Releasing

Releasing can be done as follows:

* Update the `VERSION` file
* Run `make vendor` if you have changed dependencies
* Do normal Github steps
  * Commit and push changes
  * Open PR, get approval and merge
  * Pull main
* Run `make push` from this directory. It will:
  * build and tag an image to run on your local OS
  * build an tag an image to run on linux/amd64
  * push the linux/amd64 image to a registry within the Greenhouse AWS account for interviews. Auth is required; this is built into the make target
