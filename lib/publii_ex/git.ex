defmodule PubliiEx.Git do
  @moduledoc """
  A wrapper around the git command line tool.
  """
  require Logger

  def init(cwd) do
    run(["init"], cwd)
  end

  def config(key, value, cwd) do
    run(["config", key, value], cwd)
  end

  def add(files, cwd) do
    run(["add" | List.wrap(files)], cwd)
  end

  def commit(message, cwd) do
    run(["commit", "-m", message], cwd)
  end

  def remote_add(name, url, cwd) do
    run(["remote", "add", name, url], cwd)
  end

  def remote_set_url(name, url, cwd) do
    run(["remote", "set-url", name, url], cwd)
  end

  def push(remote, branch_spec, cwd, opts \\ []) do
    args = ["push", remote, branch_spec]
    args = if opts[:force], do: args ++ ["--force"], else: args
    run(args, cwd)
  end

  def check_status(cwd) do
    run(["status"], cwd)
  end

  defp run(args, cwd) do
    Logger.debug("Running git #{Enum.join(args, " ")} in #{cwd}")

    case System.cmd("git", args, cd: cwd, stderr_to_stdout: true) do
      {output, 0} ->
        {:ok, String.trim(output)}

      {output, code} ->
        Logger.error("Git command failed (code #{code}): #{output}")
        {:error, String.trim(output)}
    end
  end
end
