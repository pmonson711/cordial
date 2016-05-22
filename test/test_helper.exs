ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Cordial.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Cordial.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Cordial.Repo)

