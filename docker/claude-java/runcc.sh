#!/bin/bash

docker run -it --rm \
    --name claude-sb \
    -v ./freedomscm-scm-tms-claude:/workspace/tms \
    -v ~/.m2:/home/developer/.m2 \
    -v ./.claude:/home/developer/.claude \
    -v ~/.ssh:/home/developer/.ssh \
    -v ~/.gitconfig:/home/developer/.gitconfig \
    -v ./.claude.json:/home/developer/.claude.json \
    --env-file .env \
    claude-java25:0.0.4