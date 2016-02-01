defmodule ExPubnub.MessagesView do
  use ExPubnub.Web, :view

  def render("publish.json", %{timestamp: timestamp}) do
    [1, "Sent", "#{timestamp}"]
  end

  def render("subscribe.json", %{messages: messages, timestamp: timestamp}) do
    [messages,"#{timestamp}"]
  end
end
