# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.5.1 (2024-07-14)

Housekeeping:
* Update deps, docs and CI
* Fix dialyzer issues

## 0.5.0 (2023-05-14)

**Potentially Breaking Changes**
* Return additional information with the errors on changesets
  * This generally shouldn't break anything, but if the code is using
    `Ecto.Changeset.traverse_errors/2` and looking at the `additional_info` it could.

Improvements:
* Add the ability to customize error messages by passing `messages` to a validator

Housekeeping:
* Update deps and docs
* Fix deprecation warning

## 0.4.1 (2020-11-11)

* Bump dependencies used for development and testing
* No user-visible changes

## 0.4.0 (2019-09-02)

**Breaking Changes**
* Extract `PasswordValidator.Validators.ZXCVBNValidator` to a separate (compatible) repository: https://github.com/axelson/password-validator-zxcvbn
* Increased minimum Elixir version to 1.7
  * Please file an issue if this is too high

## 0.3.0 (2019-04-05)

* Fix: Use a better exception message for invalid length validator configurations
* Feature: Add support for zxcvbn via https://github.com/techgaun/zxcvbn-elixir
  * Adds zxcvbn as a dependency
  * Enabled by default (use `[zxcvbn: :disabled]` to disable**
* Fix: Bump dev dependencies

**Breaking Changes**
* `PasswordValidator.Validators.ZXCVBNValidator` is enabled by default (with a
  minimum score of 2) which in many ways is more strict than the existing
  validators.
  * Pass `[zxcvbn: :disabled]` to disable ZXCVBNValidator. e.g.
    `PasswordValidator.validate_password("some password", zxcvbn: :disabled)`

## 0.2.1 (2019-01-23)

* Fix compilation warning on Elixir 1.8
** https://github.com/axelson/password-validator/pull/3
* Update dependencies

## 0.2.0 (2018-03-19)

* Handle the case when a nil password is passed in
** https://github.com/axelson/password-validator/pull/1
* Update internal dependencies

Potentially breaking changes:
* Update formatting of returned errors
** https://github.com/axelson/password-validator/pull/1

## 0.1.2 (2017-07-31)

* Add a missing typespec and this changelog

## 0.1.1 (2017-07-31)

* Doc fixes
* Upgrade elixir and dependencies

## 0.1.0 (2017-07-31)

* Initial public release 🎉
