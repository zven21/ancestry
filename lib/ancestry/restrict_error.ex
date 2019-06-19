defmodule Ancestry.RestrictError do
  defexception message: "Cannot delete record because it has descendants."
end
