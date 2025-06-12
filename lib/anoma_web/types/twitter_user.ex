defmodule AnomaWeb.Types.TwitterUser do
  @moduledoc """
  Type definitions for Twitter user data structures.
  """

  @type public_metrics :: %{
          followers_count: non_neg_integer(),
          following_count: non_neg_integer(),
          tweet_count: non_neg_integer(),
          listed_count: non_neg_integer(),
          like_count: non_neg_integer()
        }

  @type formatted_user :: %{
          id: String.t(),
          login: String.t(),
          name: String.t(),
          avatar_url: String.t() | nil,
          bio: String.t() | nil,
          verified: boolean(),
          public_metrics: public_metrics() | nil
        }

  @type user_response :: %{
          id: non_neg_integer(),
          login: String.t() | nil,
          name: String.t() | nil,
          avatar_url: String.t() | nil,
          bio: String.t() | nil,
          verified: boolean(),
          points: non_neg_integer(),
          public_metrics: public_metrics() | nil
        }

  @type raw_twitter_data :: %{
          String.t() => any()
        }
end
