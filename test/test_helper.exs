ExUnit.start

Mix.Task.run "ecto.create", ~w(-r ExPubnub.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r ExPubnub.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(ExPubnub.Repo)

