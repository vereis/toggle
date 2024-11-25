# Toggle
<!-- MDOC !-->

Toggle is a stupid-simple feature flag library for Elixir.

It provides a simple API for enabling and disabling feature flags in your application.

## Installation

Add `toggle` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:toggle, "~> 0.1.0"}
  ]
end
```

## Usage

In order to use Toggle, you need to:

1) Configure `Toggle` to use your application's Ecto Repo to store flags.
2) Add an Ecto Migration to your application to set up the database table `Toggle` will use to store data.
3) Set up `EctoHooks` in your application's Ecto Repo.

### Repo Setup & Migrations

Currently, `Toggle` supports SQLite3 and Postgres as database backends.

You can set up `Toggle` to use your application's Ecto Repo by adding the following configuration to your `config.exs`:

```elixir
config :toggle, repo: MyApp.Repo
```

Then, you can create migrations using the `Toggle.Migrations.SQLite` or `Toggle.Migrations.Postgres` helper modules:

```elixir
defmodule MyApp.Repo.Migrations.CreateFlagsTables do
  use Ecto.Migration

  def up do
    # Replace `Toggle.Migrations.SQLite` with `Toggle.Migrations.Postgres` if you are using Postgres
    Toggle.Migrations.SQLite.up(table: "toggle_flags")
  end

  def down do
    # Replace `Toggle.Migrations.SQLite` with `Toggle.Migrations.Postgres` if you are using Postgres
    Toggle.Migrations.SQLite.down(table: "toggle_flags")
  end
end
```

### EctoHooks Setup

`Toggle` uses `EctoHooks` to automatically update a cache whenever a flag is created, updated, or deleted.

Please add the following lines to your application's `Repo` module:

```elixir
use EctoMiddleware

def middleware(_action, _resource) do
  [EctoHooks.Middleware.Before, EctoMiddleware.Super, EctoHooks.Middleware.After]
end
```

This will enable `EctoHooks` for your application's `Repo` module.

Please see the documentation for `EctoHooks` for further information, though this is not needed to use `Toggle`.

### Using Toggle

After you have run your migrations and set up `EctoHooks`, you can start using `Toggle` in your application.

```elixir
iex> Toggle.enabled?("my_feature")
false
iex> Toggle.enable!("my_feature")
:ok
iex> Toggle.enabled?("my_feature")
true
```

You can also enable flags specifically for some arbitrary resource:

```elixir
iex> Toggle.disable!("my_feature")
:ok
iex> Toggle.enable!("my_feature", user_id: 123)
:ok
iex> Toggle.enabled?("my_feature")
false
iex> Toggle.enabled?("my_feature", user_id: 123)
true
```

Resources are key-value pairs that can be used to enable or disable a flag for a specific entity. The expected data
type for both the key and value is an atom, string, or integer.

Today, toggle only supports boolean flags, but we plan to add support for more flag types in the future.

Whether or not a flag is enabled is determined by the following rules:

- If a flag is enabled for a resource, that resource's value takes precedence over the global value.
- If a flag is disabled for a resource, that resource's value takes precedence over the global value.
- Otherwise, the global value is used.

> #### Info {: .info}
>
> One edge case is that `Toggle.disabled?/1` and `Toggle.disabled?/2` are implemented as inverses of `Toggle.enabled?/1` and
> `Toggle.enabled?/2` which means that if a flag does not exist, it is considered disabled.

## Caching

Querying flags on every request can be expensive, so `Toggle` provides a caching layer to speed up flag lookups.

Whenever a flag is created, updated, or deleted, we update a cache with the latest flag data using `Cachex` under the
`:toggle_cache` namespace.

Whenever the cache is mutated, `Toggle.Cache` will asynchronously publish the changes to all other connected nodes
using Erlang's `:erpc` module. In the future, we plan to add support for other pubsub strategies.

Using `Toggle.enabled?/1`, `Toggle.enabled?/2`, `Toggle.disabled?/1`, or `Toggle.disabled?/2` will automatically use
the cache if it is available.

The cache has a default ttl of one minute.

## Testing

If you're using and interacting `Toggle` in your tests, every time a flag value is created, updated, or deleted, `Toggle`
will automatically cache the state of the flag.

This can lead to unexpected results in your tests, as unlike the datastore, the cache is not reset between tests by
default.

You can reset the cache between tests by calling `Toggle.Cache.reset/0` in your test setup or teardown.

```elixir
defmodule MyApp.MyTest do
  use ExUnit.Case

  # Always reset cache at the beginning of each test.
  setup do
    Toggle.Cache.reset()
    :ok
  end

  # Or, reset the cache as tests teardown.
  setup do
    on_exit(fn -> Toggle.Cache.reset() end)
  end
end
```

## Configuration

`Toggle` aims to be as simple as possible, and as such, it does not require any configuration.

The only possible configuration at the time of writing is:

- `:repo` - The Ecto Repo to use for storing flags. Required.
- `:flag_table_name` - The name of the database table used to store flags. Defaults to `"toggle_flags"`.
- `:cache_ttl` - The time-to-live for cached flags. Defaults to 1 minute.

See `Toggle.Comptime` for more information.

## Further Reading

The core API for `Toggle` is provided by the `Toggle` module. You can use the `Toggle` module to enable and disable flags,
and check if a flag is enabled or disabled.

For more complex querying, please see the `Toggle.Flags` module, the `Toggle.Flags.Flag` schema, and the libraries
this application is built on: `EctoModel` and `EctoHooks`.

The `Toggle.Flags.Flag` schema implements the `EctoModel.Queryable` behaviour, which lends itself well to fluent-api
style querying.

For example, you are able to query flags using the `Toggle.Flags.Flag.query/2` function:

```elixir
iex> MyApp.Repo.one(Toggle.Flags.Flag.query(name: "my_flag", disabled: true))
%Toggle.Flags.Flag{name: "my_flag", enabled: false}
```

Additionally, please feel free to query the `Toggle.Flags.Flag` schema directly.

## Future Work

- Add support for more flag types such as `:percentage` and `:datetime`.
- Add support for deprecating flags and emitting deprecation warnings after a certain date.
- Add support for hooks that can be run before or after a flag is enabled or disabled.
- Add support for disabling the cache -- useful for tests.
- Pluggable pub/sub strategies.
- Add a `Phoenix.LiveView` interface for managing flags in real-time.
    - Including metrics and analytics for flag usage.
