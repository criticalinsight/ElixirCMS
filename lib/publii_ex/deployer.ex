defmodule PubliiEx.Deployer do
  require Logger
  alias PubliiEx.Git

  def deploy(site) do
    method = site.deploy_method || "github"
    Logger.info("Starting deployment for site #{site.name} via #{method}...")

    output_dir = Path.join("output", "sites/#{site.id}")

    if File.dir?(output_dir) do
      # Support both legacy key and new nested key
      hooks = site.settings["hooks"] || %{}
      post_build = hooks["post_build"] || site.settings["post_build_hook"]

      result =
        case method do
          "cloudflare" -> deploy_cloudflare(site, output_dir)
          # Deprecated/Hidden GitHub method
          "github" -> deploy_github(site, output_dir)
          "hook" -> run_hook(post_build, output_dir)
          _ -> {:error, "Unsupported deployment method: #{method}"}
        end

      if method != "hook" && post_build do
        run_hook(post_build, output_dir)
      end

      result
    else
      Logger.error("Output directory does not exist: #{output_dir}")
      {:error, "Build output not found. Please build the site first."}
    end
  end

  def deploy_cloudflare(site, output_dir) do
    Logger.info("Deploying to Cloudflare Pages...")

    token = site.cloudflare_api_token
    account_id = site.cloudflare_account_id
    project_name = site.cloudflare_project || site.slug

    if token && account_id do
      # Set up environment variables for wrangler
      env = [
        {"CLOUDFLARE_ACCOUNT_ID", account_id},
        {"CLOUDFLARE_API_TOKEN", token}
      ]

      args = [
        "wrangler",
        "pages",
        "deploy",
        ".",
        "--project-name",
        project_name,
        "--branch",
        "main",
        "--commit-dirty=true"
      ]

      # Check if npx is available
      # On Windows, we need to run via cmd /c to handle .cmd/.bat files correctly
      {cmd, cmd_args} =
        if match?({:win32, _}, :os.type()) do
          {"cmd", ["/c", "npx" | args]}
        else
          # On Unix, standard npx in path should work, or find absolute path
          npx_path = System.find_executable("npx") || "npx"
          {npx_path, args}
        end

      Logger.info("Running wrangler deploy for project: #{project_name}")

      case System.cmd(cmd, cmd_args, cd: output_dir, env: env, stderr_to_stdout: true) do
        {output, 0} ->
          Logger.info("Cloudflare deployment successful!\n#{output}")
          :ok

        {output, code} ->
          Logger.error("Cloudflare deployment failed (code #{code}): #{output}")
          {:error, "Wrangler failed: #{output}"}
      end
    else
      {:error, "Cloudflare Account ID and API Token are required."}
    end
  end

  defp deploy_github(site, output_dir) do
    Logger.info("Deploying to GitHub...")

    if site.github_repo && site.github_token do
      # Construct URL with auth token
      repo_url =
        "https://x-access-token:#{site.github_token}@github.com/#{site.github_repo}.git"

      with {:ok, _} <- Git.init(output_dir),
           {:ok, _} <- Git.config("user.name", "Publii-Ex Deployer", output_dir),
           {:ok, _} <- Git.config("user.email", "deployer@publii-ex.local", output_dir),
           # Add remote handling - handle if it already exists or not
           _ <- Git.remote_add("origin", repo_url, output_dir),
           {:ok, _} <- Git.remote_set_url("origin", repo_url, output_dir),
           {:ok, _} <- Git.add(".", output_dir),
           {:ok, _} <- Git.commit("Deploy site - #{DateTime.utc_now()}", output_dir),
           {:ok, _} <- Git.push("origin", "main:gh-pages", output_dir, force: true) do
        Logger.info("Deployment successful!")
        :ok
      else
        {:error, reason} ->
          Logger.error("Deployment failed: #{reason}")
          {:error, reason}
      end
    else
      {:error, "GitHub repository and token are required for deployment."}
    end
  end

  def run_hook(nil, _cwd), do: :ok

  def run_hook(command, cwd) do
    Logger.info("Running post-build hook: #{command}")

    case System.shell(command, cd: cwd, stderr_to_stdout: true) do
      {output, 0} ->
        Logger.info("Hook completed: #{output}")
        :ok

      {output, code} ->
        Logger.error("Hook failed (code #{code}): #{output}")
        {:error, "Hook failed: #{output}"}
    end
  end
end
