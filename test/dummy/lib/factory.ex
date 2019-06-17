defmodule Dummy.Factory do
  use ExMachina.Ecto, repo: Dummy.Repo

  def category_factory do
    %Dummy.Category{
      name: sequence(:name, &"name_#{&1}")
    }
  end
end
