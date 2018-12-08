defmodule MastaniServer.Test.Billing do
  use MastaniServer.TestTools

  import Helper.Utils, only: [get_config: 2]

  alias Helper.ORM
  alias MastaniServer.Accounts.User
  alias MastaniServer.Billing

  @seninor_amount_threshold get_config(:general, :seninor_amount_threshold)

  setup do
    {:ok, user} = db_insert(:user)

    valid_attrs = mock_attrs(:bill)

    {:ok, ~m(user valid_attrs)a}
  end

  describe "[billing curd]" do
    @tag :wip
    test "create bill record with valid attrs", ~m(user valid_attrs)a do
      {:ok, record} = Billing.create_record(user, valid_attrs)

      assert record.amount == @seninor_amount_threshold
      assert record.payment_usage == "donate"
      assert record.state == "pending"
      assert record.user_id == user.id
      assert String.length(record.hash_id) == 8
    end

    @tag :wip
    test "create bill record with valid note", ~m(user valid_attrs)a do
      {:ok, record} = Billing.create_record(user, valid_attrs |> Map.merge(%{note: "i am girl"}))

      assert record.note == "i am girl"
    end

    @tag :wip
    test "create bill record with previous record unhandled fails", ~m(user valid_attrs)a do
      {:ok, _record} = Billing.create_record(user, valid_attrs)
      {:error, error} = Billing.create_record(user, valid_attrs)
      assert error |> Keyword.get(:code) == ecode(:exsit_pending_bill)
    end

    @tag :wip
    test "record state can be update", ~m(user valid_attrs)a do
      {:ok, record} = Billing.create_record(user, valid_attrs)

      {:ok, updated} = Billing.update_record_state(record.id, :done)
      assert updated.state == "done"
    end

    @tag :wip
    test "can get paged bill records of a user", ~m(user valid_attrs)a do
      {:ok, _record} = Billing.create_record(user, valid_attrs)

      {:ok, records} = Billing.list_records(user, %{page: 1, size: 20})

      records |> is_valid_pagination?(:raw)
      assert records.entries |> List.first() |> Map.get(:user_id) == user.id
    end
  end

  describe "[after billing]" do
    @tag :wip
    test "user updgrade to seninor_member after seninor bill handled", ~m(user valid_attrs)a do
      attrs = valid_attrs |> Map.merge(%{amount: @seninor_amount_threshold})

      {:ok, record} = Billing.create_record(user, attrs)
      {:ok, updated} = Billing.update_record_state(record.id, :done)

      {:ok, %{achievement: achievement}} = ORM.find(User, user.id, preload: :achievement)
      assert achievement.seninor_member == true
    end

    @tag :wip
    test "user updgrade to donate_member after donate bill handled", ~m(user valid_attrs)a do
      attrs = valid_attrs |> Map.merge(%{amount: @seninor_amount_threshold - 10})

      {:ok, record} = Billing.create_record(user, attrs)
      {:ok, updated} = Billing.update_record_state(record.id, :done)

      {:ok, %{achievement: achievement}} = ORM.find(User, user.id, preload: :achievement)
      assert achievement.donate_member == true
    end

    @tag :wip
    test "girls updgrade to seninor_member after bill handled", ~m(user valid_attrs)a do
      attrs = valid_attrs |> Map.merge(%{amount: 0, payment_usage: "girls_code_too_plan"})

      {:ok, record} = Billing.create_record(user, attrs)
      {:ok, updated} = Billing.update_record_state(record.id, :done)

      {:ok, %{achievement: achievement}} = ORM.find(User, user.id, preload: :achievement)
      assert achievement.seninor_member == true
    end

    @tag :wip
    test "sponsor updgrade to seninor_member after bill handled", ~m(user valid_attrs)a do
      attrs = valid_attrs |> Map.merge(%{amount: 0, payment_usage: "sponsor"})

      {:ok, record} = Billing.create_record(user, attrs)
      {:ok, updated} = Billing.update_record_state(record.id, :done)

      {:ok, %{achievement: achievement}} = ORM.find(User, user.id, preload: :achievement)
      assert achievement.sponsor_member == true
    end
  end
end
