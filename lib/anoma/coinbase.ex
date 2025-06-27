defmodule Anoma.Coinbase do
  use WebSockex

  @url "wss://ws-feed-public.sandbox.exchange.coinbase.com"

  def start_link(_) do
    {:ok, pid} = WebSockex.start_link(@url, __MODULE__, %{})
    subscription = %{"channels" => ["ticker"], "product_ids" => ["BTC-USD"], "type" => "subscribe"}
    WebSockex.send_frame(pid, {:text, Jason.encode!(subscription)})
    {:ok, pid}
  end

  def handle_frame({type, msg}, state) do
    IO.puts "Received Message - Type: #{inspect type} -- Message: #{inspect msg}"
    {:ok, state}
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    IO.puts "Sending #{type} frame with payload: #{msg}"
    {:reply, frame, state}
  end
end
