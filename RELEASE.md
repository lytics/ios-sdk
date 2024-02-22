# Release Instructions

This package uses the [swift-version-file-plugin](https://github.com/Mobelux/swift-version-file-plugin) Swift Package Manager command plugin to maintain a source file--[`Sources/Lytics/Version.swift`](Sources/Lytics/Version.swift)--enabling the SDK to report its version to the Lytics API. To ensure that this is properly maintained, releases should only be created using the [`Prepare Release`](https://github.com/lytics/ios-sdk/actions/workflows/prepare-release.yml) workflow. Run it using `workflow_dispatch` event trigger from the `main` branch with the appropriate release type to create a new PR on a `release` branch containing an update to the Version file. Add any additional changes related to the release, like updating a changelog, to this PR. Finally, merge the `release` branch into `main` to delete it and trigger the [`Create Release`](.github/workflows/create-release.yml) workflow. This will create a new tag corresponding to the value of the updated Version file and a new release.