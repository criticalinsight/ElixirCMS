defmodule PubliiEx.AI.Persona do
  @callback name() :: String.t()
  @callback prompt(String.t()) :: String.t()
  @callback model() :: String.t()
end
