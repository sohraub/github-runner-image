FROM ubuntu:20.04

# Set the github runner version, default to 3.312.0
ARG RUNNER_VERSION=2.312.0

# Install pre-reqs with apt
RUN apt-get update -y && apt-get upgrade -y; \
    DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y --no-install-recommends \ 
    tzdata curl jq ca-certificates;

# Add a runner user and download the requisite files from GitHub,
# unzipping the files into a folder where the runner user has permissions
RUN useradd -m runner; \
    cd /home/runner && mkdir actions-runner && cd actions-runner; \
    curl -O -L \
    https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz; \
    tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz; \
    chown -R runner ~runner; 

# Run the script to install remaining runner dependencies
RUN /home/runner/actions-runner/bin/installdependencies.sh;

# Copy over the start.sh script from local context
ADD start.sh .
RUN chmod +x ./start.sh

# Since the config and run script for Actions are not allowed to be run by root,
# set the user to "runner" so all subsequent commands are run as the runner user
USER runner

# Set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]
