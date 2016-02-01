defmodule ExPubNubTest.Integration.MessagesTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias ExPubnub.Router

  @opts Router.init([])

  test "publish using a valid publish key" do
    conn = conn(:get, "/publish/demo/demo/0/hello_world/0/%22Hello%20World%22")
    response = Router.call(conn, @opts)

    [1, "Sent", timestamp] = response.resp_body |> Poison.decode!
    assert Regex.match?(~r/\d+/, timestamp)
  end

  test "subscribe to a single channel using a valid subscribe key" do
    conn = conn(:get, "/subscribe/demo/hello_world/0/0")
    response = Router.call(conn, @opts)

    [[], timestamp] = response.resp_body |> Poison.decode!
    assert Regex.match?(~r/\d+/, timestamp)
  end

  test "blocks on subscribe to a single channel until a new message is published" do
    # Get initial timetoken
    conn = conn(:get, "/subscribe/demo/hello_world/0/0")
    response = Router.call(conn, @opts)
    [[], timestamp] = response.resp_body |> Poison.decode!

    # Subscribe using timetoken
    conn = conn(:get, "/subscribe/demo/hello_world/0/" <> timestamp)
    parent = self()

    # Make request in a background process
    spawn fn -> send(parent, {:response, Router.call(conn, @opts)}) end
    :timer.sleep 100

    # Publish a message to the channel
    Phoenix.PubSub.broadcast(ExPubnub.PubSub, "hello_world", {:publish, "%22Hello%20World%22"})

    # Got response
    response = receive do
      {:response, resp} -> resp
    end
    [[message], new_timestamp] = response.resp_body |> Poison.decode!

    assert Regex.match?(~r/\d+/, new_timestamp)
    assert timestamp != new_timestamp
    assert message == "%22Hello%20World%22"
  end
end
