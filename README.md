# PasswordValidator

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

Example usage:

```
iex> opts = [
....   length: [min: 5, max: 30],
.... ]
iex> changeset = Ecto.Changeset.change({%{password: "simple_pass"}, %{}}, %{})
#Ecto.Changeset<action: nil, changes: %{}, errors: [],
 data: %{password: "simple_pass"}, valid?: true>
iex> changeset = PasswordValidator.validate(changeset, :password, opts)
#Ecto.Changeset<action: nil, changes: %{},
 errors: [password: {"String is too short. Got 11 needed 20", []}],
 data: %{password: "simple_pass"}, valid?: false>
```

Full example:
```
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
#Ecto.Changeset<action: nil, changes: %{}, errors: [],
 data: %{password: "Simple_pass12345"}, valid?: true>
iex> changeset = PasswordValidator.validate(changeset, :password, opts)
#Ecto.Changeset<action: nil, changes: %{},
 errors: [password: {"Too many special (got 1 max was 0)", []},
  password: {"Too many numbers (got 5 max was 4)", []},
  password: {"Not enough upper_case characters (got 1 needed 3)", []}],
 data: %{password: "Simple_pass12345"}, valid?: false>
```

PasswordValidator can also be run directly on a String:

```
iex> opts = [
...>   length: [max: 6],
...> ]
iex> PasswordValidator.validate_password("too_long", opts)
{:error, ["String is too long. Got 8 needed 6"]}
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

## Constraints

* Doesn't deal well with non-latin characters
* Currently always pulls in Ecto as a dependency

## Contributing

To run the default test suite, run `mix test`

PR's and discussions welcome!
