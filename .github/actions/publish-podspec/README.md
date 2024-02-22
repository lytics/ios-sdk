# Publish Podspec

A GitHub Action to publish a CocoaPods podspec.

## Inputs

```yaml
inputs:
  podspec-path:
    description: The path to the podspec file.
    required: true
  version:
    description: The version of the podspec to publish.
    required: true
```

## Example Usage

```yaml
name: Publish Podspec
on:
  workflow_dispatch:
jobs:
  publish-cocoapods:
    runs-on: macOS-latest
    steps:
      - name: Git checkout
        uses: actions/checkout@v4

      - name: Publish Pod
        id: publish-example
        uses: ./.github/actions/publish-podspec
        with:
          podspec-path: Example.podspec
          version: $(git describe --tags `git rev-list --tags --max-count=1`)
        env:
          COCOAPODS_TRUNK_TOKEN: ${{ secrets.COCOAPODS_TRUNK_TOKEN }}
```

## Acknowledgements

Inspired by the [Deploy to Cocoapod Action](https://github.com/michaelhenry/deploy-to-cocoapods-github-action).
