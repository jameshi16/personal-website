#!/bin/bash
# Pushes stuff to GitHub. Uses environment variables: USERNAME, GITHUB_TOKEN, BRANCH and REPOSITORY
# This is a separate script to hide the token from the GitHub runner output

cd built
git config user.name "CodingIndex Deploy"
git config user.email "deploy@codingindex.xyz"
git add .
git commit -m "Deployment from GitHub runner"
git push https://${USERNAME}:${GITHUB_TOKEN}@github.com/${REPOSITORY} gh-pages:${BRANCH}
cd -
