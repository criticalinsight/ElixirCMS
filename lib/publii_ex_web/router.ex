defmodule PubliiExWeb.Router do
  use PubliiExWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {PubliiExWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", PubliiExWeb do
    pipe_through(:browser)

    # Dashboard (multisite home)
    live("/", DashboardLive)

    # Site-scoped routes
    live("/sites/:site_id", SiteLive.Overview)
    live("/sites/:site_id/posts", PostsLive.Index, :index)
    live("/sites/:site_id/posts/new", PostsLive.Edit, :new)
    live("/sites/:site_id/posts/:id/edit", PostsLive.Edit, :edit)
    live("/sites/:site_id/pages", PagesLive.Index, :index)
    live("/sites/:site_id/pages/new", PagesLive.Edit, :new)
    live("/sites/:site_id/pages/:id/edit", PagesLive.Edit, :edit)
    live("/sites/:site_id/media", MediaLive)
    live("/sites/:site_id/theme", ThemeLive.Editor)
    live("/sites/:site_id/plugins", PluginsLive.Index)
    live("/sites/:site_id/settings", SettingsLive)

    # Legacy routes (redirect or remove later)
    get("/legacy", PageController, :home)
    live("/settings", SettingsLive)
  end

  # Other scopes may use custom stacks.
  # scope "/api", PubliiExWeb do
  #   pipe_through :api
  # end
end
