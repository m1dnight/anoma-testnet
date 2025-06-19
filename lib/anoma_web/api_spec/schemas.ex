defmodule AnomaWeb.ApiSpec.Schemas do
  @moduledoc """
  Specifications of common return values from the api.
  """
  alias OpenApiSpex.Schema

  defmodule User do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      # The title is optional. It defaults to the last section of the module name.
      # So the derived title for MyApp.User is "User".
      title: "user",
      type: :object,
      properties: %{
        id: %Schema{type: :integer, description: "user id", example: 1},
        twitter_id: %Schema{type: :string, description: "twitter id", example: "1234567890"},
        points: %Schema{type: :integer, description: "points", example: 100},
        confirmed_at: %Schema{
          type: :string,
          description: "confirmed at",
          example: "2021-01-01T00:00:00Z"
        },
        twitter_username: %Schema{type: :string, description: "twitter username", example: "user"},
        twitter_name: %Schema{type: :string, description: "twitter name", example: "user"},
        twitter_avatar_url: %Schema{
          type: :string,
          description: "twitter avatar url",
          example: "https://pbs.twimg.com/profile_images/1234567890/image.png"
        },
        twitter_bio: %Schema{type: :string, description: "twitter bio", example: "user"},
        twitter_verified: %Schema{type: :boolean, description: "twitter verified", example: true},
        twitter_public_metrics: %Schema{
          type: :object,
          description: "twitter public metrics",
          example: %{
            followers_count: 100,
            following_count: 100,
            tweet_count: 100,
            listed_count: 100
          }
        },
        auth_provider: %Schema{type: :string, description: "auth provider", example: "twitter"},
        email: %Schema{type: :string, description: "email", example: "user@example.com"},
        eth_address: %Schema{type: :string, description: "eth address", example: "0x1234567890"},
        inserted_at: %Schema{
          type: :string,
          description: "inserted at",
          example: "2021-01-01T00:00:00Z"
        },
        updated_at: %Schema{
          type: :string,
          description: "updated at",
          example: "2021-01-01T00:00:00Z"
        }
      }
    })
  end

  defmodule JsonError do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      # The title is optional. It defaults to the last section of the module name.
      # So the derived title for MyApp.User is "User".
      title: "json error",
      type: :object,
      properties: %{
        error: %Schema{type: :string, description: "error message", example: "not found"},
        success: %Schema{type: :boolean, description: "success message", example: false}
      },
      example: %{error: "not found", success: false}
    })
  end

  defmodule JsonSuccess do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      # The title is optional. It defaults to the last section of the module name.
      # So the derived title for MyApp.User is "User".
      title: "json success",
      type: :object,
      properties: %{
        success: %Schema{type: :boolean, description: "success message", example: true}
      },
      example: %{success: true}
    })
  end

  defmodule DailyPoint do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      # The title is optional. It defaults to the last section of the module name.
      # So the derived title for MyApp.User is "User".
      title: "daily point",
      type: :object,
      properties: %{
        id: %Schema{
          type: :string,
          description: "unique identifier",
          example: "331e0c6f-dd52-4be2-8039-2fd5acea283e"
        },
        day: %Schema{
          type: :string,
          description: "date string for the day of the reward",
          example:
            "F2DF174E0417CE8F063A2AA27DAB78D5BC950504C77A3E18FE4D0FF4BCEA04EC8066E1ABFF7E9443758EE0D7014BC388FA0D92E99FE6518035CF0770FCD494EF"
        },
        claimed: %Schema{
          type: :boolean,
          description: "boolean indicating the reward being claimed or not",
          example: false
        }
      },
      example: %{
        id: "fc7b0093-d318-497a-a678-66d30c6a6261",
        location:
          "F2DF174E0417CE8F063A2AA27DAB78D5BC950504C77A3E18FE4D0FF4BCEA04EC8066E1ABFF7E9443758EE0D7014BC388FA0D92E99FE6518035CF0770FCD494EF",
        day: "2025-06-19",
        claimed: false
      }
    })
  end
end
