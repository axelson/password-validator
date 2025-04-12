# Cutting a Release

Bump the version in mix.exs and CHANGELOG.md

```
mix hex.publish
git tag v0.5.2 # use specific version number
git push --tags
```

View the hexdocs to ensure that they were published correctly

References:
* https://hex.pm/docs/publish
