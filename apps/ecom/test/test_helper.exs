ExUnit.start(exclue: [:skip])

Application.ensure_all_started(:bypass)

Ecto.Adapters.SQL.Sandbox.mode(Ecom.Repo, :manual)
