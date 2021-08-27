# PasswordValidator

[![Module Version](https://img.shields.io/hexpm/v/password_validator.svg)](https://hex.pm/packages/password_validator)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/password_validator/)
[![Total Download](https://img.shields.io/hexpm/dt/password_validator.svg)](https://hex.pm/packages/password_validator)
[![License](https://img.shields.io/hexpm/l/password-validator.svg)](https://github.com/axelson/password-validator/blob/master/LICENSE.md)
[![Last Updated](https://img.shields.io/github/last-commit/axelson/password-validator.svg)](https://github.com/axelson/password-validator/commits/master)

PasswordValidator is a library to validate passwords, makes sense doesn't it? By
default two validators are built in, but it is also possible to create your own
custom validator for more advanced usage.

Validators:
* LengthValidator - validates the length of the password
* CharacterSetValidator - validates the characters contained within the
  password, number of lower case, number of upper case, number of special
  characters, etc.
* [ZXCVBNValidator](https://github.com/axelson/password-validator-zxcvbn) - Uses
  Dropbox's [zxcvbn](https://github.com/dropbox/zxcvbn) algorithm to rate
  passwords

The primary use case is validating an `%Ecto.Changeset{}`

## Installation

`PasswordValidator` is [available in Hex](https://hex.pm/packages/password_validator), the package can be installed
by adding `password_validator` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:password_validator, "~> 0.4"},
  ]
end
```

The docs can be found at [https://hexdocs.pm/password_validator](https://hexdocs.pm/password_validator).

## Usage

PasswordValidator will typically be used within the changeset function of an Ecto schema:

``` elixir
@password_opts [
  length: [min: 7, max: 30, messages: [too_short: "Password is too short!"]],
  character_set: [
    lower_case: 5,  # at least five lower case letters
    upper_case: [3, :infinity], # at least three upper case letters
    numbers: [1, 4],  # from 1 to 4 number characters
    special: [0, 0],  # no special characters allowed
  ]
]

def changeset(user, attrs) do
  user
  |> cast(attrs, [:name, :age, :password])
  |> validate_required([:name, :age, :password])
  # Add this to your changeset
  |> PasswordValidator.validate(:password, @password_opts)
end
```

Example interactive usage:

``` elixir
iex> opts = [
...>   length: [min: 12, max: 30],
...> ]
iex> changeset = Ecto.Changeset.change({%{password: "simple_pass"}, %{}}, %{})
#Ecto.Changeset<action: nil, changes: %{}, errors: [], data: %{password: "simple_pass"}, valid?: true>
iex> PasswordValidator.validate(changeset, :password, opts)
#Ecto.Changeset<action: nil, changes: %{}, errors: [password: {"String is too short. Only 11 characters instead of 12", [validator: PasswordValidator.Validators.LengthValidator, error_type: :too_short]}], data: %{password: "simple_pass"}, valid?: false>
```

Full example:
``` elixir
iex> opts = [
...>   length: [min: 5, max: 30],
...>   character_set: [
...>     lower_case: 1,  # at least one lower case letter
...>     upper_case: [3, :infinity], # at least three upper case letters
...>     numbers: [0, 4],  # at most 4 numbers
...>     special: [0, 0],  # no special characters allowed
...>   ]
...> ]
iex> changeset = Ecto.Changeset.change({%{password: "Simple_pass12345"}, %{}}, %{})
iex> changeset = PasswordValidator.validate(changeset, :password, opts)
iex> changeset.errors
[password: {"Too many special (1 but maximum is 0)", [
  {:validator, PasswordValidator.Validators.CharacterSetValidator},
  {:error_type, :too_many_special}
]},
password: {"Too many numbers (5 but maximum is 4)", [
  {:validator, PasswordValidator.Validators.CharacterSetValidator},
  {:error_type, :too_many_numbers}
]},
password: {"Not enough upper_case characters (only 1 instead of at least 3)", [
  {:validator, PasswordValidator.Validators.CharacterSetValidator},
  {:error_type, :too_few_upper_case}
]}]
```

If you want to check that a PasswordValidator error was added then in the changeset's errors field you can check that there is an error with the key `:validator`

PasswordValidator can also be run directly on a String:

```
iex> opts = [
...>   length: [max: 6],
...> ]
iex> PasswordValidator.validate_password("too_long", opts)
{:error, ["String is too long. 8 but maximum is 6"]}
```

Note: The `CharacterSetValidator` set of allowed special characters defaults to
any character that is not lower case, upper case, or a number. If the
`CharacterSetValidator` is passed `allowed_special_characters` (as a string)
then just those characters will be considered as special characters and any
other characters will be considered "other" and will fail the password check.
For full details see the `CharacterSetValidator` docs.

Note: On an invalid configuration the library will raise an error.

## Custom validators

Custom Validators need to implement the `PasswordValidator.Validator` behaviour.
Currently the only callback is `validate`. They can then be supplied as options (to either `PasswordValidator.validate/3` or `PasswordValidator.validate_password/2`)

## Constraints

* Doesn't deal well with non-latin characters
* Currently always pulls in Ecto as a dependency

## Contributing

To run the default test suite, run `mix test`

PR's and discussions welcome!

## Copyright and License

Copyright (c) 2017 Jason Axelson

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
