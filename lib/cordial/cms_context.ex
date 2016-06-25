defmodule Cordial.CmsContext do
  alias Cordial.Util.Calendar

  defstruct [
    auth_confirm_timestamp: "",
    auth_session_id: :empty,
    auth_timestamp: "",
    auth_user_id: :unkown,
    acl: nil,
    user_id: :unknown
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
end
