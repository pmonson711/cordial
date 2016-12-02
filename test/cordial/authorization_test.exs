defmodule Cordial.AuthorizationTest do
  use ExUnit.Case
  alias Cordial.Authorization
  alias Cordial.Notification
  alias Cordial.CmsContext
  alias Cordial.Utils

  defmodule AlwaysConfirmed do
    use GenEvent

    def handle_call({:auth_confirm, %CmsContext{new_user_id: new_user_id} = context}, _) do
      context
      |> Map.put(:auth_is_confirmed, true)
      |> Map.put(:user_id, new_user_id)
      |> Notification.map_response
    end

    def handle_call({:user_is_enabled, _}, _) do
      Notification.map_response true
    end

    def handle_call({:auth_logon, %CmsContext{} = context}, _) do
      context
      |> Map.put(:auth_user_id, 1)
      |> Map.put(:auth_session_id, 1)
      |> Notification.map_response
    end
  end

  setup_all do
    Notification.add_handler(AlwaysConfirmed, :user_is_enabled)
    Notification.add_handler(AlwaysConfirmed, :auth_confirm)
    Notification.add_handler(AlwaysConfirmed, :auth_logon)
    :ok
  end

  test "Can confirm user" do
    {:ok, cms_context} = Authorization.confirm(1)
    assert %CmsContext{user_id: 1} = cms_context
    assert %CmsContext{auth_is_confirmed: true} = cms_context
    refute "" == Map.get(cms_context, :auth_confirm_timestamp)
  end

  test "Can logon user" do
    {:ok, cms_context} = Authorization.logon(1)

    assert %CmsContext{user_id: 1} = cms_context
    assert %CmsContext{auth_is_confirmed: true} = cms_context
    assert %CmsContext{auth_user_id: 1} = cms_context
    assert %CmsContext{auth_session_id: 1} = cms_context
    refute "" == Map.get(cms_context, :auth_confirm_timestamp)
  end

  test "Can logoff user" do
    {:ok, cms_context} = Authorization.logon(1)
    |> Utils.unwrap_ok_tuple
    |> Authorization.logoff

    assert %CmsContext{user_id: 1} = cms_context
    assert %CmsContext{auth_is_confirmed: false} = cms_context
    assert %CmsContext{auth_user_id: :unknown} = cms_context
    assert %CmsContext{auth_session_id: :empty} = cms_context
    assert %CmsContext{auth_confirm_timestamp: ""} = cms_context
    assert %CmsContext{impersonation_chain: []} = cms_context
  end
end
