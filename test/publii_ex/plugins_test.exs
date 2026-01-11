defmodule PubliiEx.PluginsTest do
  use ExUnit.Case

  alias PubliiEx.{Repo, Plugins, Generator}

  @site_id "test_site_plugins"

  setup do
    # Create a test site
    site = %PubliiEx.Site{
      id: @site_id,
      name: "Plugin Test Site",
      base_url: "http://example.com/"
    }

    Repo.save_site(site)

    # Clean up plugins for this site
    Repo.delete("site:#{@site_id}:plugin:giscus")
    Repo.delete("site:#{@site_id}:plugin:snipcart")

    on_exit(fn ->
      Repo.delete_site(@site_id)
      File.rm_rf!("output/sites/#{@site_id}")
    end)

    {:ok, site: site}
  end

  test "can install and list plugins" do
    assert Plugins.list_installed_plugins(@site_id) == []

    assert :ok = Plugins.install(@site_id, :giscus)

    installed = Plugins.list_installed_plugins(@site_id)
    assert length(installed) == 1
    assert hd(installed).id == :giscus

    assert Plugins.is_installed?(@site_id, :giscus)
  end

  test "plugins hooks are executed and injected", %{site: _site} do
    # 1. Install Giscus
    Plugins.install(@site_id, :giscus)

    # 2. Configure Giscus
    settings = %{
      "repo" => "test/repo",
      "repo_id" => "123",
      "category" => "General",
      "category_id" => "456"
    }

    Plugins.save_settings(@site_id, :giscus, settings)

    # 3. Build Site
    # Create a dummy post to ensure rendering happens
    post = %PubliiEx.Post{
      id: "plugin-post",
      title: "Plugin Post",
      slug: "plugin-post",
      status: :published,
      published_at: DateTime.utc_now()
    }

    Repo.save_post_for_site(@site_id, post)

    {:ok, output_dir} = Generator.build(@site_id)

    # 4. Verify Output
    index_path = Path.join(output_dir, "index.html")
    assert File.exists?(index_path)

    content = File.read!(index_path)

    # Since Giscus injects into body, check for the script
    assert content =~ "giscus.app/client.js"
    assert content =~ "data-repo=\"test/repo\""
  end

  test "snipcart injection", %{site: _site} do
    Plugins.install(@site_id, :snipcart)
    Plugins.save_settings(@site_id, :snipcart, %{"api_key" => "TEST_API_KEY"})

    {:ok, output_dir} = Generator.build(@site_id)
    index_path = Path.join(output_dir, "index.html")
    content = File.read!(index_path)

    # Check Head (CSS)
    assert content =~ "snipcart.css"
    # Check Body (JS + Div)
    assert content =~ "snipcart.js"
    assert content =~ "data-api-key=\"TEST_API_KEY\""
  end
end
