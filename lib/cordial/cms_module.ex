defmodule Cordial.CmsModule do
  def start_link do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Registry, [:unique, Registry.CmsModules], id: Registry.CmsModules),
      supervisor(Registry, [:unique, Registry.CmsRouters], id: Registry.CmsRouters)
    ]

    opts = [strategy: :one_for_one, name: Cordial.CmsModule.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
