defmodule PubliiEx.Images do
  @moduledoc """
  Provides a curated list of high-quality Unsplash images for the "Platinum Insider" vibe.
  These images are used when the API key is not available or for consistent aesthetics.
  """

  # Curated list of high-res images: Business, Technology, Markets, Abstract
  @curated_images [
    # Blue abstract financial
    "https://images.unsplash.com/photo-1611974765270-ca12586343bb?q=80&w=1920&auto=format&fit=crop",
    # Stock market graph
    "https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?q=80&w=1920&auto=format&fit=crop",
    # Coins/Money
    "https://images.unsplash.com/photo-1526304640152-d4619684e484?q=80&w=1920&auto=format&fit=crop",
    # Abstract mesh
    "https://images.unsplash.com/photo-1518186285589-2f7649de83e0?q=80&w=1920&auto=format&fit=crop",
    # Skyscrapers
    "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=1920&auto=format&fit=crop",
    # Earth data network
    "https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=1920&auto=format&fit=crop",
    # Analytics dashboard
    "https://images.unsplash.com/photo-1551288049-bebda4e38f71?q=80&w=1920&auto=format&fit=crop",
    # Meeting
    "https://images.unsplash.com/photo-1556761175-5973dc0f32e7?q=80&w=1920&auto=format&fit=crop",
    # Suit/Business
    "https://images.unsplash.com/photo-1507679799987-c73779587ccf?q=80&w=1920&auto=format&fit=crop",
    # Minimalist dark
    "https://images.unsplash.com/photo-1535320903710-d9cf11287755?q=80&w=1920&auto=format&fit=crop",
    # Crypto/Blockchain
    "https://images.unsplash.com/photo-1642543492481-44e81e3914a7?q=80&w=1920&auto=format&fit=crop",
    # Abstract dark blue
    "https://images.unsplash.com/photo-1639322537228-ad7117a39434?q=80&w=1920&auto=format&fit=crop",
    # Chart close up
    "https://images.unsplash.com/photo-1460925895917-afdab827c52f?q=80&w=1920&auto=format&fit=crop",
    # Abstract flowing money
    "https://images.unsplash.com/photo-1579532537598-459ecdaf39cc?q=80&w=1920&auto=format&fit=crop",
    # Work desk
    "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?q=80&w=1920&auto=format&fit=crop",
    # Money closeup
    "https://images.unsplash.com/photo-1434626881859-194d67b2b86f?q=80&w=1920&auto=format&fit=crop",
    # Team working
    "https://images.unsplash.com/photo-1519389950473-47ba0277781c?q=80&w=1920&auto=format&fit=crop",
    # Golden Gate/Bridge
    "https://images.unsplash.com/photo-1502920514313-52581002a659?q=80&w=1920&auto=format&fit=crop",
    # Cybersecurity
    "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?q=80&w=1920&auto=format&fit=crop",
    # Abstract geometric
    "https://images.unsplash.com/photo-1529400971008-f566de0e6dfc?q=80&w=1920&auto=format&fit=crop"
  ]

  def get_random_image do
    Enum.random(@curated_images)
  end

  def get_all, do: @curated_images
end
