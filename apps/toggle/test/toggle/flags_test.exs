defmodule Toggle.FlagsTest do
  use Toggle.DataCase

  alias Toggle.Flags
  alias Toggle.Flags.Flag
  alias Toggle.Repo

  def insert_flag(attrs \\ []) do
    {:ok, %Flag{} = flag} =
      %{name: Ecto.UUID.generate(), enabled: false}
      |> Map.merge(Map.new(attrs))
      |> Flags.create_flag()

    flag
  end

  describe "create_flag/1" do
    test "creates a new flag" do
      attrs = %{name: "new_flag", description: "A new flag", enabled: true}
      assert {:ok, %Flag{} = flag} = Flags.create_flag(attrs)

      assert flag.name == "new_flag"
      assert flag.description == "A new flag"
      assert flag.type == :boolean
      assert flag.meta == %{}
      assert flag.enabled
    end
  end

  describe "update_flag/2" do
    test "given a flag, updates it accordingly" do
      assert %Flag{} = flag = insert_flag()
      assert {:ok, updated_flag} = Flags.update_flag(flag, %{enabled: true})

      refute flag.enabled
      assert updated_flag.enabled

      assert flag.id == updated_flag.id
    end
  end

  describe "delete_flag/1" do
    test "given a flag, deletes it" do
      assert %Flag{} = flag = insert_flag()
      assert {:ok, deleted_flag} = Flags.delete_flag(flag)

      assert flag.id == deleted_flag.id
      refute Repo.exists?(Flag.query(id: flag.id))
    end
  end

  describe "get_flag/2" do
    setup do
      %Flag{} = flag = insert_flag()
      {:ok, binding()}
    end

    test "given a filter, returns the flag", ctx do
      assert %Flag{} = flag = Flags.get_flag(name: ctx.flag.name)
      assert flag.id == ctx.flag.id
    end

    test "given a flag name (string), returns the flag", ctx do
      assert %Flag{} = flag = Flags.get_flag(ctx.flag.name)
      assert flag.id == ctx.flag.id
    end

    test "given a flag name (atom), returns the flag", ctx do
      assert %Flag{} = flag = Flags.get_flag(String.to_atom(ctx.flag.name))
      assert flag.id == ctx.flag.id
    end

    test "given a flag name (string) and filters returns the flag", ctx do
      assert %Flag{} = flag = Flags.get_flag(ctx.flag.name, enabled: false)
      assert flag.id == ctx.flag.id
    end

    test "given a flag name (atom) and filters returns the flag", ctx do
      assert %Flag{} = flag = Flags.get_flag(String.to_atom(ctx.flag.name), enabled: false)
      assert flag.id == ctx.flag.id
    end

    test "given a flag name (string) that does not exist, returns nil" do
      assert is_nil(Flags.get_flag(Ecto.UUID.generate()))
    end

    test "given a flag name (atom) that does not exist, returns nil" do
      assert is_nil(Flags.get_flag(:does_not_exist))
    end

    test "given filters that don't match any flags, returns nil" do
      assert is_nil(Flags.get_flag(enabled: true))
    end

    test "given a name (string) and filters that don't match any flags, returns nil", ctx do
      assert is_nil(Flags.get_flag(ctx.flag.name, enabled: true))
    end

    test "given a name (atom) and filters that don't match any flags, returns nil", ctx do
      assert is_nil(Flags.get_flag(String.to_atom(ctx.flag.name), enabled: true))
    end
  end

  describe "list_flags/1" do
    setup do
      %Flag{} = flag = insert_flag()
      {:ok, binding()}
    end

    test "returns empty list when filters don't match any flags" do
      assert [] == Flags.list_flags(enabled: true)
    end

    test "returns all flags given no filters", ctx do
      assert [flag] = Flags.list_flags()
      assert flag.id == ctx.flag.id
    end

    test "returns all flags matching the given filters", ctx do
      assert [flag] = Flags.list_flags(id: ctx.flag.id)
      assert flag.id == ctx.flag.id
    end
  end

  describe "enabled?/1" do
    setup do
      %Flag{} = enabled_flag = insert_flag(enabled: true)
      %Flag{} = disabled_flag = insert_flag(enabled: false)
      {:ok, binding()}
    end

    test "given a flag, returns whether or not its enabled", ctx do
      assert Flags.enabled?(ctx.enabled_flag)
      refute Flags.enabled?(ctx.disabled_flag.name)
    end

    test "given a flag name (string), returns whether or not its enabled", ctx do
      assert Flags.enabled?(ctx.enabled_flag.name)
      refute Flags.enabled?(ctx.disabled_flag.name)
    end

    test "given a flag name (atom), returns whether or not its enabled", ctx do
      assert Flags.enabled?(String.to_atom(ctx.enabled_flag.name))
      refute Flags.enabled?(String.to_atom(ctx.disabled_flag.name))
    end
  end
end
