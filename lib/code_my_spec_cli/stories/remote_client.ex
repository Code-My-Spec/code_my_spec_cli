defmodule CodeMySpecCli.Stories.RemoteClient do
  @moduledoc """
  HTTP client for Stories API using Req.
  Used in CLI to communicate with remote server.
  """

  require Logger

  alias CodeMySpec.Stories.Story
  alias CodeMySpec.Users.Scope
  alias CodeMySpecCli.Auth.OAuthClient

  @doc """
  Returns the list of stories.
  """
  def list_stories(%Scope{} = scope) do
    case get_request(scope, "/api/stories") do
      {:ok, %{status: 200, body: %{"data" => stories}}} ->
        Enum.map(stories, &deserialize_story/1)

      {:ok, %{status: 401}} ->
        raise "Authentication failed. Please run 'codemyspec auth login' to re-authenticate."

      {:error, reason} ->
        raise "Failed to list stories: #{inspect(reason)}"
    end
  end

  def list_project_stories(%Scope{} = scope) do
    case get_request(scope, "/api/stories-list/project") do
      {:ok, %{status: 200, body: %{"data" => stories}}} ->
        {:ok, Enum.map(stories, &deserialize_story/1)}

      {:ok, %{status: 401}} ->
        {:error, :authentication_failed}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def list_project_stories_paginated(%Scope{} = scope, opts \\ []) do
    case list_project_stories(scope) do
      {:ok, stories} ->
        search = Keyword.get(opts, :search)
        tag = Keyword.get(opts, :tag)
        limit = Keyword.get(opts, :limit, 20)
        offset = Keyword.get(opts, :offset, 0)

        filtered =
          stories
          |> maybe_filter_search(search)
          |> maybe_filter_tag(tag)

        total = length(filtered)
        page = filtered |> Enum.drop(offset) |> Enum.take(limit)
        {page, total}

      {:error, reason} ->
        raise "Failed to list stories: #{inspect(reason)}"
    end
  end

  def list_story_titles(%Scope{} = scope, opts \\ []) do
    case list_project_stories(scope) do
      {:ok, stories} ->
        search = Keyword.get(opts, :search)

        stories
        |> maybe_filter_search(search)
        |> Enum.sort_by(& &1.title)
        |> Enum.map(&%{id: &1.id, title: &1.title, component_id: &1.component_id})

      {:error, reason} ->
        raise "Failed to list story titles: #{inspect(reason)}"
    end
  end

  def list_project_stories_by_priority(%Scope{} = scope) do
    case get_request(scope, "/api/stories-list/by-priority") do
      {:ok, %{status: 200, body: %{"data" => stories}}} ->
        Enum.map(stories, &deserialize_story/1)

      {:ok, %{status: 401}} ->
        raise "Authentication failed. Please run 'codemyspec auth login' to re-authenticate."

      {:error, reason} ->
        raise "Failed to list project stories by priority: #{inspect(reason)}"
    end
  end

  def list_project_stories_by_component_priority(%Scope{} = scope) do
    case get_request(scope, "/api/stories-list/by-component-priority") do
      {:ok, %{status: 200, body: %{"data" => stories}}} ->
        Enum.map(stories, &deserialize_story/1)

      {:ok, %{status: 401}} ->
        raise "Authentication failed. Please run 'codemyspec auth login' to re-authenticate."

      {:error, reason} ->
        raise "Failed to list project stories by component priority: #{inspect(reason)}"
    end
  end

  def list_unsatisfied_stories(%Scope{} = scope) do
    case get_request(scope, "/api/stories-list/unsatisfied") do
      {:ok, %{status: 200, body: %{"data" => stories}}} ->
        Enum.map(stories, &deserialize_story/1)

      {:ok, %{status: 401}} ->
        raise "Authentication failed. Please run 'codemyspec auth login' to re-authenticate."

      {:error, reason} ->
        raise "Failed to list unsatisfied stories: #{inspect(reason)}"
    end
  end

  def list_component_stories(%Scope{} = scope, component_id) do
    case get_request(scope, "/api/stories-list/component/#{component_id}") do
      {:ok, %{status: 200, body: %{"data" => stories}}} ->
        Enum.map(stories, &deserialize_story/1)

      {:ok, %{status: 401}} ->
        []

      {:error, :not_authenticated} ->
        []

      {:error, _reason} ->
        []
    end
  end

  @doc """
  Gets a single story. Returns nil if not found.
  """
  def get_story(%Scope{} = scope, id) do
    case get_request(scope, "/api/stories/#{id}") do
      {:ok, %{status: 200, body: %{"data" => story}}} ->
        deserialize_story(story)

      {:ok, %{status: 404}} ->
        nil

      {:error, reason} ->
        raise "Failed to get story: #{inspect(reason)}"
    end
  end

  @doc """
  Gets a single story. Raises if not found.
  """
  def get_story!(%Scope{} = scope, id) do
    case get_story(scope, id) do
      nil -> raise Ecto.NoResultsError, queryable: Story
      story -> story
    end
  end

  @doc """
  Creates a story.
  """
  def create_story(%Scope{} = scope, attrs) do
    case post_request(scope, "/api/stories", %{story: attrs}) do
      {:ok, %{status: 201, body: %{"data" => story}}} ->
        {:ok, deserialize_story(story)}

      {:ok, %{status: 422, body: body}} ->
        {:error, build_changeset_error(attrs, body)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Updates a story.
  """
  def update_story(%Scope{} = scope, %Story{} = story, attrs) do
    case put_request(scope, "/api/stories/#{story.id}", %{story: attrs}) do
      {:ok, %{status: 200, body: %{"data" => updated_story}}} ->
        {:ok, deserialize_story(updated_story)}

      {:ok, %{status: 404}} ->
        {:error, :not_found}

      {:ok, %{status: 422, body: body}} ->
        {:error, build_changeset_error(attrs, body)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Deletes a story.
  """
  def delete_story(%Scope{} = scope, %Story{} = story) do
    case delete_request(scope, "/api/stories/#{story.id}") do
      {:ok, %{status: 200, body: %{"data" => deleted_story}}} ->
        {:ok, deserialize_story(deleted_story)}

      {:ok, %{status: 404}} ->
        {:error, :not_found}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Sets the component that satisfies a story.
  """
  def set_story_component(%Scope{} = scope, %Story{} = story, component_id) do
    case post_request(scope, "/api/stories/#{story.id}/set-component", %{
           component_id: component_id
         }) do
      {:ok, %{status: 200, body: %{"data" => updated_story}}} ->
        {:ok, deserialize_story(updated_story)}

      {:ok, %{status: 404}} ->
        {:error, :not_found}

      {:ok, %{status: 422, body: body}} ->
        {:error, build_changeset_error(%{}, body)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Clears the component assignment from a story.
  """
  def clear_story_component(%Scope{} = scope, %Story{} = story) do
    case post_request(scope, "/api/stories/#{story.id}/clear-component", %{}) do
      {:ok, %{status: 200, body: %{"data" => updated_story}}} ->
        {:ok, deserialize_story(updated_story)}

      {:ok, %{status: 404}} ->
        {:error, :not_found}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Private functions

  defp get_request(scope, path) do
    base_url = get_base_url()
    Logger.debug("[RemoteClient] GET #{base_url}#{path}")

    case get_oauth_token(scope) do
      {:ok, token} ->
        Logger.debug("[RemoteClient] Token obtained: #{String.slice(token, 0, 20)}...")
        result = Req.get(
          url: "#{base_url}#{path}",
          headers: [{"authorization", "Bearer #{token}"}],
          decode_json: [keys: :strings]
        )
        case result do
          {:ok, resp} -> Logger.debug("[RemoteClient] Response status: #{Map.get(resp, :status)}")
          {:error, err} -> Logger.debug("[RemoteClient] Request error: #{inspect(err)}")
        end
        result

      {:error, reason} = error ->
        Logger.warning("[RemoteClient] Token fetch failed: #{inspect(reason)}")
        error
    end
  end

  defp post_request(scope, path, body) do
    base_url = get_base_url()

    with {:ok, token} <- get_oauth_token(scope) do
      Req.post(
        url: "#{base_url}#{path}",
        json: body,
        headers: [{"authorization", "Bearer #{token}"}],
        decode_json: [keys: :strings]
      )
    end
  end

  defp put_request(scope, path, body) do
    base_url = get_base_url()

    with {:ok, token} <- get_oauth_token(scope) do
      Req.put(
        url: "#{base_url}#{path}",
        json: body,
        headers: [{"authorization", "Bearer #{token}"}],
        decode_json: [keys: :strings]
      )
    end
  end

  defp delete_request(scope, path) do
    base_url = get_base_url()

    with {:ok, token} <- get_oauth_token(scope) do
      Req.delete(
        url: "#{base_url}#{path}",
        headers: [{"authorization", "Bearer #{token}"}],
        decode_json: [keys: :strings]
      )
    end
  end

  defp get_base_url do
    Application.get_env(:code_my_spec, :api_base_url) ||
      raise "API base URL not configured. Please set :api_base_url in config."
  end

  defp get_oauth_token(%Scope{} = _scope) do
    OAuthClient.get_token()
  end

  defp deserialize_story(data) do
    %Story{
      id: data["id"],
      title: data["title"],
      description: data["description"],
      acceptance_criteria: data["acceptance_criteria"],
      criteria: parse_criteria(data["criteria"]),
      status: parse_status(data["status"]),
      priority: data["priority"],
      locked_at: parse_datetime(data["locked_at"]),
      lock_expires_at: parse_datetime(data["lock_expires_at"]),
      locked_by: data["locked_by"],
      project_id: data["project_id"],
      component_id: data["component_id"],
      account_id: data["account_id"],
      tags: parse_tags(data["tags"]),
      inserted_at: parse_datetime(data["inserted_at"]),
      updated_at: parse_datetime(data["updated_at"])
    }
  end

  defp parse_status(nil), do: nil
  defp parse_status(status) when is_binary(status), do: String.to_existing_atom(status)

  defp parse_tags(nil), do: []
  defp parse_tags(tags) when is_list(tags) do
    alias CodeMySpec.Tags.Tag
    Enum.map(tags, fn tag_data ->
      %Tag{
        id: tag_data["id"],
        name: tag_data["name"]
      }
    end)
  end

  defp parse_criteria(nil), do: []
  defp parse_criteria(criteria) when is_list(criteria) do
    alias CodeMySpec.AcceptanceCriteria.Criterion
    Enum.map(criteria, fn criterion_data ->
      %Criterion{
        id: criterion_data["id"],
        description: criterion_data["description"],
        verified: criterion_data["verified"],
        verified_at: parse_datetime(criterion_data["verified_at"]),
        story_id: criterion_data["story_id"],
        project_id: criterion_data["project_id"],
        account_id: criterion_data["account_id"],
        inserted_at: parse_datetime(criterion_data["inserted_at"]),
        updated_at: parse_datetime(criterion_data["updated_at"])
      }
    end)
  end

  defp parse_datetime(nil), do: nil

  defp parse_datetime(datetime_string) when is_binary(datetime_string) do
    case DateTime.from_iso8601(datetime_string) do
      {:ok, datetime, _offset} -> datetime
      {:error, _} -> nil
    end
  end

  defp maybe_filter_search(stories, nil), do: stories
  defp maybe_filter_search(stories, ""), do: stories

  defp maybe_filter_search(stories, search) do
    term = String.downcase(search)

    Enum.filter(stories, fn story ->
      String.contains?(String.downcase(story.title || ""), term) ||
        String.contains?(String.downcase(story.description || ""), term)
    end)
  end

  defp maybe_filter_tag(stories, nil), do: stories
  defp maybe_filter_tag(stories, ""), do: stories

  defp maybe_filter_tag(stories, tag) do
    Enum.filter(stories, fn story ->
      Enum.any?(story.tags || [], &(&1.name == tag))
    end)
  end

  defp build_changeset_error(attrs, body) do
    changeset = Story.changeset(%Story{}, attrs)

    errors =
      case body do
        %{"errors" => errors} when is_map(errors) ->
          Enum.map(errors, fn {field, messages} ->
            {String.to_existing_atom(field), {List.first(messages), []}}
          end)

        _ ->
          [base: {"Remote API error", []}]
      end

    %{changeset | errors: errors, valid?: false}
  end
end
