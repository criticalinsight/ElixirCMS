# Seed script for Haiku Blog
# Run with: mix run seed_haiku.exs

# Wait for application to be ready
Process.sleep(1000)

alias PubliiEx.{Repo, Post, SiteConfig}

# Haiku collection - 20 classic and nature-inspired haiku
haiku_posts = [
  %{
    title: "The Old Pond",
    content: "An old silent pond\nA frog jumps into the pond—\nSplash! Silence again.",
    tags: ["nature", "pond", "frog", "classic"]
  },
  %{
    title: "Autumn Moonlight",
    content: "Autumn moonlight—\na worm digs silently\ninto the chestnut.",
    tags: ["autumn", "moon", "nature"]
  },
  %{
    title: "Temple Bell",
    content: "The temple bell stops\nbut the sound keeps coming\nout of the flowers.",
    tags: ["temple", "sound", "flowers", "spiritual"]
  },
  %{
    title: "Cherry Blossoms",
    content: "In the moonlight,\nthe color and scent of the wisteria\nseems far away.",
    tags: ["moon", "wisteria", "spring"]
  },
  %{
    title: "Winter Solitude",
    content: "In the cicada's cry\nno sign can foretell\nhow soon it must die.",
    tags: ["cicada", "impermanence", "summer"]
  },
  %{
    title: "Mountain Path",
    content: "Along this road\ngoes no one,\nautumn evening.",
    tags: ["road", "solitude", "autumn"]
  },
  %{
    title: "Spring Rain",
    content: "Spring rain—\nthe umbrella vendor\nwalks in his own rain.",
    tags: ["spring", "rain", "vendor"]
  },
  %{
    title: "Summer Grass",
    content: "Summer grasses—\nall that remains\nof warriors' dreams.",
    tags: ["summer", "grass", "history", "classic"]
  },
  %{
    title: "Falling Leaves",
    content: "First autumn morning:\nthe mirror I stare into\nshows my father's face.",
    tags: ["autumn", "reflection", "family"]
  },
  %{
    title: "Winter Sea",
    content: "Winter sea—\nsea gulls\nhovering low.",
    tags: ["winter", "sea", "birds"]
  },
  %{
    title: "Sunrise",
    content: "A morning glory—\nand so today\nmay seem very long.",
    tags: ["morning", "flower", "time"]
  },
  %{
    title: "Frog Song",
    content: "Sitting quietly,\ndoing nothing,\nspring comes and the grass grows.",
    tags: ["meditation", "spring", "stillness"]
  },
  %{
    title: "Snow Falling",
    content: "From the pine tree\nsnow falls\non the plum in bloom.",
    tags: ["winter", "snow", "pine", "plum"]
  },
  %{
    title: "Evening Star",
    content: "Even in Kyoto,\nhearing the cuckoo's cry,\nI long for Kyoto.",
    tags: ["kyoto", "longing", "cuckoo"]
  },
  %{
    title: "Dragonfly",
    content: "Dragonfly—\nhow he gazes at the far away mountains\nwith those clear eyes.",
    tags: ["dragonfly", "mountains", "summer"]
  },
  %{
    title: "Harvest Moon",
    content: "Harvest moon—\nwalking around the pond\nall night long.",
    tags: ["moon", "pond", "night", "autumn"]
  },
  %{
    title: "Blossoms at Night",
    content: "Blossoms at night—\npeople going home\nfrom the theater.",
    tags: ["blossoms", "night", "people"]
  },
  %{
    title: "Mountain Temple",
    content: "So still is this temple:\nthe monk's voice chanting sutras\nabsorbed into stone.",
    tags: ["temple", "monk", "zen", "stillness"]
  },
  %{
    title: "Fireflies",
    content: "A giant firefly:\nthat way, wondering, this way,\nand passing by.",
    tags: ["firefly", "summer", "night"]
  },
  %{
    title: "Final Journey",
    content: "This road—\nno one is walking it,\ndusk in autumn.",
    tags: ["road", "autumn", "solitude", "classic"]
  }
]

# Create posts
IO.puts("Creating #{length(haiku_posts)} haiku posts...")

for {haiku, index} <- Enum.with_index(haiku_posts, 1) do
  id = "haiku-#{String.pad_leading(Integer.to_string(index), 2, "0")}"

  slug =
    haiku.title |> String.downcase() |> String.replace(~r/[^a-z0-9]+/, "-") |> String.trim("-")

  post = %Post{
    id: id,
    title: haiku.title,
    slug: slug,
    content_md: haiku.content,
    status: :published,
    # Stagger dates
    published_at: DateTime.add(DateTime.utc_now(), -index * 86400, :second),
    tags: haiku.tags,
    excerpt: String.slice(haiku.content, 0, 50) <> "..."
  }

  Repo.save_post(post)
  IO.puts("  ✓ Created: #{haiku.title}")
end

# Update site configuration
IO.puts("\nConfiguring site settings...")

config = Repo.get_config() || %SiteConfig{}

updated_config = %{
  config
  | title: "Haiku Garden",
    subtitle: "A collection of timeless Japanese poetry",
    author: "The Haiku Master",
    # Minimal theme is perfect for haiku
    theme: "minima",
    base_url: "http://localhost:4000"
}

Repo.save_config(updated_config)
IO.puts("  ✓ Site configured: #{updated_config.title}")

IO.puts("\n🌸 Haiku blog setup complete! 🌸")
IO.puts("Navigate to http://localhost:4000/posts to view the posts.")
IO.puts("Navigate to http://localhost:4000/settings to adjust the theme.")
