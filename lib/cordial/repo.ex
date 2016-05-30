defmodule Cordial.Repo do
  use Ecto.Repo, otp_app: :cordial
  use Scrivener, page_size: 10
end
