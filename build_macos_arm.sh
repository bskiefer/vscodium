#!/bin/bash


echo "### FETCHING TAGS ###"
tag_fork=$(git tag -l | tail -n 1)
cd vscodium || exit
tag_upstream=$(git tag -l | tail -n 1)

if [[ "${tag_upstream}_darwin_arm64" != "${tag_fork}" ]]; then
  tag="${tag_upstream}_darwin_arm64"

  echo "### COMPILING ###"
  rm -rf VSCode*
  rm -rf vscode
  . get_repo.sh
  SHOULD_BUILD=yes CI_BUILD=no OS_NAME=osx VSCODE_ARCH=arm64 . build.sh

  echo "### CREATING RELEASE ###"
  gh release create "${tag}" --notes "Added Darwin ARM64 binary for M1 Macs.
  Compiled on my M1 Macbook Air in just about 5 minutes 🥳"
  zip -r VSCode-darwin-arm64/VSCodium.zip VSCode-darwin-arm64/VSCodium.app -x "*.DS_Store"
  gh release upload "${tag}" VSCode-darwin-arm64/VSCodium.zip

  echo "### INSTALLING ###"
  sudo cp -r VSCode-darwin-arm64/VSCodium.app /Applications/VSCodium.app
  sudo xattr -r -d com.apple.quarantine /Applications/VSCodium.app
else
  echo "### ALREADY ON LATEST VERSION ###"
fi
