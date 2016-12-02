defmodule Cordial.CmsContext do
  alias Cordial.Utils.Calendar
  defstruct [
    auth_is_confirmed: false,
    auth_confirm_timestamp: "",
    auth_session_id: :empty,
    auth_timestamp: "",
    auth_user_id: :unknown,
    acl: nil,
    user_id: :unknown,
    new_user_id: :unknown,
    impersonation_chain: []
  ]

  def reset_session_id(cms_context) do
    %{cms_context | auth_session_id: :empty}
  end

  def set_auth_timestamp(cms_context) do
    %{cms_context | auth_timestamp: Calendar.now}
  end

  def set_auth_confirm_timestamp(cms_context) do
    %{cms_context | auth_confirm_timestamp: Calendar.now}
  end

  def reset_auth(cms_context) do
    cms_context
    |> reset_session_id
    |> Map.put(:auth_is_confirmed, false)
    |> Map.put(:auth_confirm_timestamp, "")
    |> Map.put(:auth_timestamp, "")
    |> Map.put(:auth_user_id, :unknown)
    |> Map.put(:acl, nil)
    |> Map.put(:impersonation_chain, [])
  end
end
