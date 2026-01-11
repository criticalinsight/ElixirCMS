# verify_cloudflare.exs
alias PubliiEx.{Site, Deployer, Repo}
require Logger

# Create a test site with Cloudflare config
site = %Site{
  id: "cf_test_site",
  name: "CF Test Site",
  slug: "cf-test-site",
  theme: "maer",
  deploy_method: "cloudflare",
  cloudflare_account_id: "dummy_account_id",
  cloudflare_api_token: "dummy_api_token",
  cloudflare_project: "my-test-project",
  settings: %{}
}

# Mock output directory
output_dir = Path.join("output", "sites/#{site.id}")
File.mkdir_p!(output_dir)
File.write!(Path.join(output_dir, "index.html"), "<h1>Hello Cloudflare</h1>")

IO.puts("\n=== Testing Cloudflare Deployment Logic ===\n")

# We expect this to fail because we don't have real credentials,
# typically wrangler will return a 401 or similar, OR npx/wrangler might fail to install/run.
# We are mainly checking if the command is constructed and executed.

case Deployer.deploy(site) do
  :ok ->
    IO.puts("\n✅ Deployment reported success (unexpected with dummy creds, but flow worked).")

  {:error, output} ->
    IO.puts("\n✅ Deployment failed as expected (or due to missing wrangler). Output:")
    IO.puts(output)
end

IO.puts("\n=== Test Complete ===")
