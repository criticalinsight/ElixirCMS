defmodule PubliiEx.Page do
  @derive {Jason.Encoder,
           only: [
             :id,
             :title,
             :slug,
             :content,
             :content_md,
             :content_delta,
             :status,
             :published_at
           ]}
  defstruct [:id, :title, :slug, :content, :content_md, :content_delta, :status, :published_at]

  @type t :: %__MODULE__{
          id: String.t(),
          title: String.t(),
          slug: String.t(),
          content: String.t() | nil,
          content_md: String.t(),
          content_delta: map() | nil,
          status: :draft | :published,
          published_at: DateTime.t() | nil
        }
end
