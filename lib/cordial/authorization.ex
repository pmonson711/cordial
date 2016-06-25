defmodule Cordial.Authorization do
  alias Cordial.{
    Notification,
    Identity,
    Resource,
    CmsContext,
    Authorization.Acl,
    Authorization.Repo
  }

  def confirm(user_id, cms_context) do
    if is_enabled(user_id, cms_context) do
      cms_context
      |> CmsContext.set_auth_cofirm_timestamp
      |> Notification.foldl(:auth_confirm, %CmsContext{})
      |> Notification.notify(:auth_confirm_done)
    else
      {:error, :user_not_enabled}
    end
  end

  def logon(user_id, cms_context) do
    if is_enabled(user_id, cms_context) do
      new_context = user_id
      |> Acl.logon_prefs(cms_context)
      |> CmsContext.reset_session_id
      |> CmsContext.set_auth_timestamp
      |> Map.put(:auth_user_id, :unknown)
      |> Notification.fold(:auth_logon, %CmsContext{})
      |> Notification.notify(:auth_logon_done)
      {:ok, new_context}
    else
      {:error, :user_not_enabled}
    end
  end

  def is_enabled(user_id, cms_context) do
    case Notification.first(:user_is_enabled, cms_context) do
      :nil -> Repo.is_enabled(user_id)
      other when is_boolean(other) -> other
    end
  end
end
