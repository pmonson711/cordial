defmodule Cordial.Authorization do
  alias Cordial.{
    Notification,
    CmsContext,
    Authorization.Repo,
    Utils
  }

  def confirm(cms_context \\ %CmsContext{}, user_id) do
    if is_enabled(cms_context, user_id) do
      new_context = cms_context
      |> Map.put(:new_user_id, user_id)
      |> CmsContext.set_auth_confirm_timestamp
      |> Notification.notify(:auth_confirm_start)
      |> Notification.first(:auth_confirm)
      |> Map.put(:new_user_id, :unknown)
      |> Notification.notify(:auth_confirm_done)

      {:ok, new_context}
    else
      {:error, :user_not_enabled}
    end
  end

  def logon(cms_context \\ %CmsContext{}, user_id)
  def logon(
    %CmsContext{auth_is_confirmed: true, user_id: user_id} = cms_context,
    user_id) do

    if is_enabled(cms_context, user_id) do
      new_context = cms_context
      |> CmsContext.reset_session_id
      |> CmsContext.set_auth_timestamp
      |> Map.put(:auth_user_id, :unknown)
      |> Notification.notify(:auth_logon_start)
      |> Notification.first(:auth_logon)
      |> Notification.notify(:auth_logon_done)

      {:ok, new_context}
    else
      {:error, :user_not_enabled}
    end
  end

  def logon(cms_context, user_id) do
    cms_context
    |> confirm(user_id)
    |> Utils.unwrap_ok_tuple
    |> logon(user_id)
  end

  def is_enabled(cms_context \\ %CmsContext{}, user_id) do
    case Notification.first(cms_context, :user_is_enabled) do
      :nil -> Repo.is_enabled(user_id)
      other when is_boolean(other) -> other
    end
  end

  def logoff(cms_context) do
    new_context = cms_context
    |> Notification.notify(:auth_logoff_start)
    |> CmsContext.reset_auth
    |> Notification.notify(:auth_logoff_done)

    {:ok, new_context}
  end
end
