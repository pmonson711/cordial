defmodule Cordial.CmsModule.Router do
  use Cordial.Web, :router

  scope "/", Cordial do
    get "/", PageController, :index
  end
end
