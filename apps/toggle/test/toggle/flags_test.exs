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

    test "given a flag, returns whether or not its globally enabled", ctx do
      assert Flags.enabled?(ctx.enabled_flag)
      refute Flags.enabled?(ctx.disabled_flag.name)
    end

    test "given a flag name (string), returns whether or not its globally enabled", ctx do
      assert Flags.enabled?(ctx.enabled_flag.name)
      refute Flags.enabled?(ctx.disabled_flag.name)
    end

    test "given a flag name (atom), returns whether or not its globally enabled", ctx do
      assert Flags.enabled?(String.to_atom(ctx.enabled_flag.name))
      refute Flags.enabled?(String.to_atom(ctx.disabled_flag.name))
    end

    test "given a flag that does not exist, returns false" do
      refute Flags.enabled?(Ecto.UUID.generate())
    end
  end

  describe "disabled?/1" do
    setup do
      %Flag{} = enabled_flag = insert_flag(enabled: true)
      %Flag{} = disabled_flag = insert_flag(enabled: false)
      {:ok, binding()}
    end

    test "given a flag, returns whether or not its globally enabled", ctx do
      refute Flags.disabled?(ctx.enabled_flag)
      assert Flags.disabled?(ctx.disabled_flag.name)
    end

    test "given a flag name (string), returns whether or not its globally enabled", ctx do
      refute Flags.disabled?(ctx.enabled_flag.name)
      assert Flags.disabled?(ctx.disabled_flag.name)
    end

    test "given a flag name (atom), returns whether or not its globally enabled", ctx do
      refute Flags.disabled?(String.to_atom(ctx.enabled_flag.name))
      assert Flags.disabled?(String.to_atom(ctx.disabled_flag.name))
    end

    test "given a flag that does not exist, returns true" do
      assert Flags.disabled?(Ecto.UUID.generate())
    end
  end

  describe "enabled?/2" do
    test "returns true if flag is globally enabled and not individually disabled" do
      %Flag{} = flag = insert_flag(enabled: true)
      assert Flags.enabled?(flag, org_id: 123)
    end

    test "returns true if flag is not globally enabled but is individually enabled" do
      %Flag{} = flag = insert_flag(enabled: false, meta: %{"org_id::123" => true})
      assert Flags.enabled?(flag, org_id: 123)
      refute Flags.enabled?(flag, org_id: 654)
    end

    test "returns false if flag is globally enabled but is individually disabled" do
      %Flag{} = flag = insert_flag(enabled: true, meta: %{"org_id::123" => false})
      refute Flags.enabled?(flag, org_id: 123)
      assert Flags.enabled?(flag, org_id: 654)
    end

    test "returns false if flag is not globally enabled and not individually enabled" do
      %Flag{} = flag = insert_flag(enabled: false)
      refute Flags.enabled?(flag, org_id: 123)
    end

    test "returns false if flag does not exist" do
      refute Flags.enabled?(Ecto.UUID.generate(), org_id: 123)
    end
  end

  describe "disabled?/2" do
    test "returns false if flag is globally enabled and not individually disabled" do
      %Flag{} = flag = insert_flag(enabled: true)
      refute Flags.disabled?(flag, org_id: 123)
    end

    test "returns false if flag is not globally enabled but is individually enabled" do
      %Flag{} = flag = insert_flag(enabled: false, meta: %{"org_id::123" => true})
      refute Flags.disabled?(flag, org_id: 123)
      assert Flags.disabled?(flag, org_id: 654)
    end

    test "returns true if flag is globally enabled but is individually disabled" do
      %Flag{} = flag = insert_flag(enabled: true, meta: %{"org_id::123" => false})
      assert Flags.disabled?(flag, org_id: 123)
      refute Flags.disabled?(flag, org_id: 654)
    end

    test "returns true if flag is not globally enabled and not individually enabled" do
      %Flag{} = flag = insert_flag(enabled: false)
      assert Flags.disabled?(flag, org_id: 123)
    end

    test "returns true if flag does not exist" do
      assert Flags.disabled?(Ecto.UUID.generate(), org_id: 123)
    end
  end

  describe "enable!/1" do
    test "enables the given flag" do
      %Flag{} = flag = insert_flag(enabled: false)
      assert :ok = Flags.enable!(flag)
      assert Flags.enabled?(flag.name)
    end

    test "enables the given flag by name (string)" do
      %Flag{} = flag = insert_flag(enabled: false)
      assert :ok = Flags.enable!(flag.name)
      assert Flags.enabled?(flag.name)
    end

    test "enables the given flag by name (atom)" do
      %Flag{} = flag = insert_flag(enabled: false)
      assert :ok = Flags.enable!(String.to_atom(flag.name))
      assert Flags.enabled?(flag.name)
    end

    test "enables the given flag, creating it if it did not exist" do
      refute Flags.enabled?("new_flag")
      assert :ok = Flags.enable!("new_flag")
      assert Flags.enabled?("new_flag")
    end
  end

  describe "disable!/1" do
    test "disables the given flag" do
      %Flag{} = flag = insert_flag(enabled: true)
      assert :ok = Flags.disable!(flag)
      assert Flags.disabled?(flag.name)
    end

    test "disables the given flag by name (string)" do
      %Flag{} = flag = insert_flag(enabled: true)
      assert :ok = Flags.disable!(flag.name)
      assert Flags.disabled?(flag.name)
    end

    test "disables the given flag by name (atom)" do
      %Flag{} = flag = insert_flag(enabled: true)
      assert :ok = Flags.disable!(String.to_atom(flag.name))
      assert Flags.disabled?(flag.name)
    end

    test "disables the given flag, creating it if it did not exist" do
      assert Flags.disabled?("new_flag")
      assert :ok = Flags.disable!("new_flag")
      assert Flags.disabled?("new_flag")
    end
  end

  describe "enable!/2" do
    test "enable the given flag for the given entity" do
      %Flag{} = flag = insert_flag(enabled: false)
      assert :ok = Flags.enable!(flag, org_id: 123)
      assert Flags.enabled?(flag.name, org_id: 123)
    end

    test "enable the given flag for the given entity by name (string)" do
      %Flag{} = flag = insert_flag(enabled: false)
      assert :ok = Flags.enable!(flag.name, org_id: 123)
      assert Flags.enabled?(flag.name, org_id: 123)
    end

    test "enable the given flag for the given entity by name (atom)" do
      %Flag{} = flag = insert_flag(enabled: false)
      assert :ok = Flags.enable!(String.to_atom(flag.name), org_id: 123)
      assert Flags.enabled?(flag.name, org_id: 123)
    end

    test "enable the given flag for the given entity, creating it if it did not exist" do
      refute Flags.enabled?("new_flag", org_id: 123)
      refute Flags.enabled?("new_flag", org_id: 666)
      refute Flags.enabled?("new_flag")

      assert :ok = Flags.enable!("new_flag", org_id: 123)

      assert Flags.enabled?("new_flag", org_id: 123)
      refute Flags.enabled?("new_flag", org_id: 666)
      refute Flags.enabled?("new_flag")
    end
  end

  describe "disable!/2" do
    test "disable the given flag for the given entity" do
      %Flag{} = flag = insert_flag(enabled: true)
      assert :ok = Flags.disable!(flag, org_id: 123)
      assert Flags.disabled?(flag.name, org_id: 123)
    end

    test "disable the given flag for the given entity by name (string)" do
      %Flag{} = flag = insert_flag(enabled: true)
      assert :ok = Flags.disable!(flag.name, org_id: 123)
      assert Flags.disabled?(flag.name, org_id: 123)
    end

    test "disable the given flag for the given entity by name (atom)" do
      %Flag{} = flag = insert_flag(enabled: true)
      assert :ok = Flags.disable!(String.to_atom(flag.name), org_id: 123)
      assert Flags.disabled?(flag.name, org_id: 123)
    end

    test "disable the given flag for the given entity, creating it if it did not exist" do
      assert Flags.disabled?("new_flag", org_id: 123)
      assert Flags.disabled?("new_flag", org_id: 666)
      assert Flags.disabled?("new_flag")

      assert :ok = Flags.disable!("new_flag", org_id: 123)

      assert Flags.disabled?("new_flag", org_id: 123)
      assert Flags.disabled?("new_flag", org_id: 666)
      assert Flags.disabled?("new_flag")
    end
  end

  describe "encode_meta!/2" do
    test "returns the encoded meta key" do
      assert "org_id::123" == Flags.encode_meta!(:org_id, 123)
    end
  end

  describe "decode_meta!/2" do
    test "returns resource given encoded meta" do
      assert [{"org_id", "123"}] == Flags.decode_meta!("org_id::123")
    end
  end
end
