defmodule Anoma.Coinbase do
  @moduledoc """
  I implement a websocket connection to listen for events from the Coinbase websocket.
  """
  use WebSockex

  if Mix.env() == :prod do
    @url "wss://ws-feed.exchange.coinbase.com"
  else
    @url "wss://ws-feed-public.sandbox.exchange.coinbase.com"
  end

  def start_link(_) do
    {:ok, pid} = WebSockex.start_link(@url, __MODULE__, %{})

    subscription = generate_subscription_message()

    WebSockex.send_frame(pid, {:text, Jason.encode!(subscription)})
    {:ok, pid}
  end

  def handle_frame({_type, msg}, state) do
    process_message(msg)
    {:ok, state}
  end

  def handle_cast({:send, {_type, _msg} = frame}, state) do
    {:reply, frame, state}
  end

  # ----------------------------------------------------------------------------
  # Helpers

  # parse the message and store it
  defp process_message(msg) do
    case parse_message(msg) do
      {:ok, %{product_id: ticker, price: price}} ->
        {price, ""} = Float.parse(price)

      # Anoma.Pricing.create_currency(%{currency: ticker, price: price})

      _ ->
        :noop
    end
  end

  # parse the message from the websocket
  defp parse_message(msg) do
    case Jason.decode(msg, keys: :atoms) do
      {:ok, map} ->
        {:ok, map}

      _ ->
        {:error, :failed_to_parse}
    end
  end

  # generate a signature for the coinbase api
  defp generate_signature do
    coinbase_secret = Application.get_env(:anoma, :coinbase_secret)

    timestamp = DateTime.utc_now() |> DateTime.to_unix(:native)
    message = "#{timestamp}GET/users/self/verify"
    hmac_key = Base.decode64!(coinbase_secret)
    signature = :crypto.mac(:hmac, :sha256, hmac_key, message) |> Base.encode64()
    {signature, timestamp}
  end

  # generate the subscription message with the api key
  def generate_subscription_message do
    coinbase_api_key = Application.get_env(:anoma, :coinbase_api_key)
    {signature, timestamp} = generate_signature()

    %{
      timestamp: timestamp,
      type: "subscribe",
      signature: signature,
      key: coinbase_api_key,
      channels: ["ticker"],
      product_ids: ["BTC-USD"],
      passphrase: ""
    }
  end
end
