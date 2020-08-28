# docker-nuker

[![CircleCI](https://circleci.com/gh/trussworks/docker-nuker/tree/master.svg?style=svg)](https://circleci.com/gh/trussworks/docker-nuker/tree/master)

This image is used to nuke AWS resources in an entire account.

This docker image is built off of CircleCI's most basic convenience image [`cimg/base`](https://hub.docker.com/r/cimg/base) with the following tools installed on top:

- [AWS CLI](https://aws.amazon.com/cli/)
- [AWS-Nuke](https://github.com/rebuy-de/aws-nuke)
