defmodule Wallaby.Node.QueryTest do
  use Wallaby.SessionCase, async: true

  alias Wallaby.Node
  alias Wallaby.Node.Query

  describe "find/3" do
    @tag :pending
    test "asserts all conditions" do
      flunk "Pending"
    end

    @tag :pending
    test "sends the query to the driver" do
      flunk "Pending"
    end

    @tag :pending
    test "throws appropriate errors for conditions" do
      flunk "Pending"
    end
  end

  describe "build_query/3" do
    test "assigns the parent of the query" do
      parent = %Node{}
      locator = {:css, ".user"}
      query = Query.build_query(parent, locator, [])

      assert query.parent == parent
    end

    test "builds the correct locator" do
      parent = %Node{}
      locator = {:css, ".user"}
      query = Query.build_query(parent, locator, [])

      assert query.locator == locator
    end

    test "merges default conditions" do
      parent = %Node{}
      locator = {:css, ".user"}
      query = Query.build_query(parent, locator, [])

      assert query.conditions == [visible: true, count: 1]
    end

    test "doesn't override user specified conditions" do
      parent = %Node{}
      locator = {:css, ".user"}
      query = Query.build_query(parent, locator, [visible: false, count: :any])

      assert query.conditions == [visible: false, count: :any]
    end

    test "defaults to no errors" do
      parent = %Node{}
      locator = {:css, ".user"}
      query = Query.build_query(parent, locator, [visible: false, count: :any])

      assert query.errors == []
    end
  end
end
