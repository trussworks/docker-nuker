# docker-template

[![CircleCI](https://circleci.com/gh/trussworks/docker-template/tree/master.svg?style=svg)](https://circleci.com/gh/trussworks/docker-template/tree/master)

This repository is meant to serve as both an example and a template for new docker images with our general format.

This particular example creates a docker image built off of CircleCI's most basic convenience image [`cimg/base`](https://hub.docker.com/r/cimg/base) with the following tools installed on top:

- AWS CLI
- CircleCI CLI
- ShellCheck

## Note about downstream images

In the source code for docker images like [circleci-docker-primary](https://github.com/trussworks/circleci-docker-primary), the code for downstream images are also contained in the same repository. We've decided to not pursue this route for the images replacing `circleci-docker-primary`. While this does mean we have to manage and track more repositories, it also means we don't have to worry about the complexity of figuring out which image needs to be built and released whenever a commit is made.

## Developer Setup

```sh
brew install pre-commit docker
```

## Creating a new Docker Image

Below is a quick summary of what needs to be done to create a new docker image. Steps 3-5 are expanded on.

1. Clone this repo.
2. Replace every instance of `trussworks/docker-template` with the name of your new image.
3. Modify Dockerfile to create your own image.
4. Modify `scripts/test` to reflect the changes you made in Dockerfile.
5. Register the image in Docker Hub.
6. Set up CircleCI to build and release the image to Docker Hub.

### Installing New Tools

In the Dockerfile, there's several examples of how we install different tools that are wrapped in a tar or zip, but how do we get the link for the asset and how do we get the SHA256 sum of that asset?

We'll run through an example of fetching those two data points for the latest CircleCI CLI release.

For CircleCI CLI and other tools, we do this by navigating to the GitHub repository housing the code for the tool. We then figure out which is the latest GitHub release for CircleCI CLI. (At this time, the latest release is [v0.19321](https://github.com/CircleCI-Public/circleci-cli/releases/tag/v0.1.9321).)

In the release page, we'll find a list of assets. We're particularly interested in the `circleci-cli_0.1.9321_linux_amd64.tar.gz` asset as our image is built off of a 64-bit Linux system. First, we'll download this asset on our local machine. We can do this by clicking on the asset and downloading it through our browser but, for the sake of this tutorial, let's download it via `curl` instead. Copy the link location of the asset and save it as we'll need this in our Dockerfile. Now run the following:

```sh
curl -sSLO https://github.com/CircleCI-Public/circleci-cli/releases/download/v0.1.9321/circleci-cli_0.1.9321_linux_amd64.tar.gz
```

The asset should now be on our machine. Along with the link, we also need the SHA256SUM of the asset.

```sh
sha256sum circleci-cli_0.1.9321_linux_amd64.tar.gz
```

The first string of the output is the sum we need for our Dockerfile.

Congrats! You now know how to get the direct link to download a release and the SHA256 sum of a particular download asset.

### Registering the Image

Before we start, you need a Docker Hub account and that account needs to be an owner of the TrussWorks organization on Docker Hub. Make a request in #truss-infra if that's not the case.

Now to register the image, we need to navigate to the Docker Hub. Sign-in with your account and you should automatically be placed in a page of Docker repositories. If you don't see the existing repositories for TrussWorks, click the top-left dropdown menu and select `trussworks`.

You should see a blue button with the text `Create Repository`. Click it. Fill out the name and description of our new TrussWorks Docker repository. Keep it public and double-check it is being built under TrussWorks, not your personal account. Ignore the build settings and click `Create`.

With that, you've registered your image!

### Set up CircleCI to build and release the image

Along with making sure you have a Docker Hub account that is an owner of the TrussWorks organization, make sure you have access to the credentials of the `trussworksbot` account in the org.

Again, sign into Docker Hub with your account. Find the repository you're setting up CircleCI for. You should see a tab called `Permissions` in the repository. After clicking it, grant `read & write` permissions to "bots". (There seems to be a glitch where the `Permissions` tab is sometimes replaced with `Collaborators`. If this happens, navigate to that tab and modify the url in your address bar by replacing "collaborators" with "permissions".)

Next, we'll create a personal access token for your docker image to avoid using the `trussworksbot` password in CircleCI. Log out of your Docker Hub account and sign in as the `trussworksbot`. Click the account's name on the top right of the Docker Hub page and click `Account Settings`.

Navigate to `Security`. In here you can create a new access token with the description named after the repository. Copy the access token and add it to the 1Password entry for the `trussworksbot` account.

Finally, navigate to the project's settings on the CircleCI app. In there, create an environment variable called DOCKER_USER. The value for this will be `trussworksbot`. Then create another environment variable. This one will be called DOCKER_PASS. The value for this will be the personal access token you copied.

And that's it! CircleCI is set up to build and release your docker image.
