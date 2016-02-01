defmodule ExPubnub.Router do
  use ExPubnub.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExPubnub do
    pipe_through :api

    get "/publish/:pub_key/:sub_key/:signature/:channel/:callback/:message", MessagesController, :publish
    get "/subscribe/:sub_key/:channel/:callback/:timetoken", MessagesController, :subscribe
  end
end
