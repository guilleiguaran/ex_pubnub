defmodule ExPubnub.MessagesController do
  use ExPubnub.Web, :controller

  def publish(conn, %{"pub_key" => pub_key, "sub_key" => sub_key, "signature" => _, "channel" => channel, "callback" => _, "message" => message}) do
    timestamp = :erlang.system_time()
    Phoenix.PubSub.broadcast(ExPubnub.PubSub, channel, {:publish, message})
    render(conn, timestamp: timestamp)
  end

  def subscribe(conn, %{"sub_key" => sub_key, "channel" => channel, "callback" => _, "timetoken" => timetoken}) do
    messages = case timetoken do
            "0" -> []
           time -> retrieve_new_messages(channel, time)
    end

    render(conn, messages: messages, timestamp: :erlang.system_time())
  end

  defp retrieve_new_messages(channel, timestamp) do
    Phoenix.PubSub.subscribe(ExPubnub.PubSub, self, channel)
    receive do
      {:publish, message} ->
        Phoenix.PubSub.unsubscribe(ExPubnub.PubSub, self, channel)
        [message]
      _ ->
        retrieve_new_messages(channel, timestamp)
    end
  end
end
