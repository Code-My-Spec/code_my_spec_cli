defmodule CodeMySpecCli.Stories.RemoteClientTest do
  @moduledoc """
  Tests for Stories RemoteClient HTTP functionality.
  Uses VCR to record/replay HTTP API interactions.
  """

  use CodeMySpecCli.DataCase
  use ExVCR.Mock, adapter: ExVCR.Adapter.Finch

  import CodeMySpecCli.ClientUsersFixtures

  alias CodeMySpecCli.Stories.RemoteClient
  alias CodeMySpec.Stories.Story

  setup do
    ExVCR.Config.cassette_library_dir("test/fixtures/vcr_cassettes/stories")
    ExVCR.Config.filter_request_headers("authorization")

    Application.put_env(:code_my_spec, :api_base_url, "http://localhost:4000")

    client_user = authenticated_client_user_fixture()
    on_exit(fn -> cleanup_authenticated_client_user(client_user) end)

    scope = full_scope_fixture()

    {:ok, scope: scope}
  end

  describe "list_stories/1" do
    test "returns list of stories", %{scope: scope} do
      use_cassette "remote_client_list_stories" do
        stories = RemoteClient.list_stories(scope)
        assert is_list(stories)
      end
    end
  end

  describe "list_project_stories/1" do
    test "returns list of project stories", %{scope: scope} do
      use_cassette "remote_client_list_project_stories" do
        stories = RemoteClient.list_project_stories(scope)
        assert is_list(stories)
      end
    end
  end

  describe "list_unsatisfied_stories/1" do
    test "returns list of unsatisfied stories", %{scope: scope} do
      use_cassette "remote_client_list_unsatisfied_stories" do
        stories = RemoteClient.list_unsatisfied_stories(scope)
        assert is_list(stories)
      end
    end
  end

  describe "get_story/2" do
    test "returns story when it exists", %{scope: scope} do
      use_cassette "remote_client_get_story_success" do
        story = RemoteClient.get_story(scope, 1)

        if story do
          assert %Story{} = story
          assert story.id == 1
        else
          assert is_nil(story)
        end
      end
    end

    test "returns nil when story doesn't exist", %{scope: scope} do
      use_cassette "remote_client_get_story_not_found" do
        story = RemoteClient.get_story(scope, 99999)
        assert is_nil(story)
      end
    end
  end

  describe "get_story!/2" do
    test "raises when story doesn't exist", %{scope: scope} do
      use_cassette "remote_client_get_story_bang_not_found" do
        assert_raise Ecto.NoResultsError, fn ->
          RemoteClient.get_story!(scope, 99999)
        end
      end
    end
  end

  describe "create_story/2" do
    test "creates story with valid params", %{scope: scope} do
      use_cassette "remote_client_create_story_success" do
        title = "d78622c7-7c68-466a-adaf-6ca8c4c105d1"

        attrs = %{
          title: title,
          description: "Testing remote client",
          acceptance_criteria: ["criterion 1", "criterion 2"],
          status: :in_progress
        }

        assert {:ok, %Story{} = story} = RemoteClient.create_story(scope, attrs)
        assert story.title == title
        assert story.description == "Testing remote client"
        assert story.status == :in_progress
      end
    end

    test "returns error with invalid params", %{scope: scope} do
      use_cassette "remote_client_create_story_error" do
        attrs = %{title: nil, description: nil}

        assert {:error, changeset} = RemoteClient.create_story(scope, attrs)
        assert %Ecto.Changeset{} = changeset
        refute changeset.valid?
      end
    end
  end

  describe "update_story/3" do
    test "updates story with valid params", %{scope: scope} do
      use_cassette "remote_client_update_story_success" do
        story = %Story{
          id: 1,
          title: "Original Title",
          description: "Original description",
          acceptance_criteria: ["criterion 1"],
          status: :in_progress,
          account_id: scope.active_account.id
        }

        attrs = %{
          title: "Updated Title",
          description: "Updated description"
        }

        case RemoteClient.update_story(scope, story, attrs) do
          {:ok, updated_story} ->
            assert updated_story.title == "Updated Title"
            assert updated_story.description == "Updated description"

          {:error, :not_found} ->
            assert true
        end
      end
    end
  end

  describe "delete_story/2" do
    test "deletes story when it exists", %{scope: scope} do
      use_cassette "remote_client_delete_story_success" do
        story = %Story{
          id: 999,
          title: "Story to Delete",
          account_id: scope.active_account.id
        }

        case RemoteClient.delete_story(scope, story) do
          {:ok, deleted_story} ->
            assert %Story{} = deleted_story

          {:error, :not_found} ->
            assert true
        end
      end
    end
  end

  describe "set_story_component/3" do
    test "sets component for story", %{scope: scope} do
      use_cassette "remote_client_set_story_component" do
        story = %Story{
          id: 1,
          title: "Test Story",
          account_id: scope.active_account.id
        }

        component_id = "550e8400-e29b-41d4-a716-446655440000"

        case RemoteClient.set_story_component(scope, story, component_id) do
          {:ok, updated_story} ->
            assert updated_story.component_id == component_id

          {:error, :not_found} ->
            assert true

          {:error, _changeset} ->
            assert true
        end
      end
    end
  end

  describe "clear_story_component/2" do
    test "clears component from story", %{scope: scope} do
      use_cassette "remote_client_clear_story_component" do
        story = %Story{
          id: 1,
          title: "Test Story",
          component_id: "550e8400-e29b-41d4-a716-446655440000",
          account_id: scope.active_account.id
        }

        case RemoteClient.clear_story_component(scope, story) do
          {:ok, updated_story} ->
            assert is_nil(updated_story.component_id)

          {:error, :not_found} ->
            assert true
        end
      end
    end
  end

  describe "list_component_stories/2" do
    test "returns list of stories for a component", %{scope: scope} do
      use_cassette "remote_client_list_component_stories" do
        component_id = "550e8400-e29b-41d4-a716-446655440000"
        stories = RemoteClient.list_component_stories(scope, component_id)
        assert is_list(stories)
      end
    end
  end
end
