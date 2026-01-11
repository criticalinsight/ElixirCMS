# Create a New Post
# Usage: mix run new_post.exs "My Post Title" "Optional Markdown Content"

defmodule NewPost do
  alias PubliiEx.{Post, Repo, Slug}

  def create(title, content_md \\ "") do
    slug = Slug.from_title(title)
    id = :os.system_time(:millisecond)

    post = %Post{
      id: to_string(id),
      title: title,
      slug: slug,
      content_md: content_md,
      featured_image: PubliiEx.Images.get_random_image(),
      published_at: DateTime.utc_now(),
      status: :published,
      tags: []
    }

    Repo.save_post(post)
    IO.puts("✅ Created Post: #{title} (#{slug})")
    post
  end
end

# Parse args
args = System.argv()

case args do
  [title | rest] ->
    content = Enum.join(rest, " ")
    NewPost.create(title, content)

  [] ->
    IO.puts("Usage: mix run new_post.exs \"My Post Title\" \"Optional content...\"")
end
