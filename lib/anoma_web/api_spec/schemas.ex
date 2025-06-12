defmodule AnomaWeb.ApiSpec.Schemas do
  alias OpenApiSpex.Schema

  defmodule User do
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
end
