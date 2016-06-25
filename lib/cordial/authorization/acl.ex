defmodule Cordial.Authorization.Acl do
  alias Cordial.{Notification, CmsContext}

  def logon(user_id, cms_context) do
    case Notification.first(:acl_logon, user_id) do
      nil -> %CmsContext{user_id: user_id, acl: nil}
      %CmsContext{} = new_context -> new_context
    end
  end

  def logon_prefs(user_id, cms_context) do
    Notification.foldl(:acl_logon_prefs, user_id, logon(user_id, cms_context))
  end
end
