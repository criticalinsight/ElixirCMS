defmodule PubliiEx.Plugin do
  @moduledoc """
  The interface that all PubliiEx plugins must implement.
  """
  use Phoenix.Component

  @type site_id :: String.t()
  @type config :: map()

  @callback id() :: atom()
  @callback name() :: String.t()
  @callback description() :: String.t()
  @callback install(site_id) :: :ok | {:error, any()}
  @callback uninstall(site_id) :: :ok | {:error, any()}

  # Renders the settings UI for this plugin.
  # The plugin should handle its own form state via the passed-in ID or event messaging if needed,
  # or simpler: just render inputs that the generic settings page can verify.
  # For MVP, we'll assume it renders a form part.
  @callback render_settings(assigns :: map()) :: Phoenix.LiveView.Rendered.t()

  # Returns a map of hooks this plugin subscribes to.
  # Keys are hook names. Values are functions.
  #
  # Supported Hooks:
  # - :head          -> (context) :: String.t()  (Injected into <head>)
  # - :body          -> (context) :: String.t()  (Injected before </body>)
  # - :pre_build     -> (site_id) :: :ok         (Run before build starts)
  # - :post_build    -> (output_dir) :: :ok      (Run after build completes)
  # - :transform     -> (content, context) :: content (Content processing pipeline)
  # - :sidebar       -> (site_id) :: [{name, path, icon}] (Inject menu items)
  @callback hooks() :: %{optional(atom()) => (any() -> any())}

  defmacro __using__(_) do
    quote do
      @behaviour PubliiEx.Plugin
      use Phoenix.Component

      def install(_site_id), do: :ok
      def uninstall(_site_id), do: :ok
      def hooks(), do: %{}

      defoverridable install: 1, uninstall: 1, hooks: 0
    end
  end
end
