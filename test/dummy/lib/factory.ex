defmodule Dummy.Factory do
  use ExMachina.Ecto, repo: Dummy.Repo

  def category_factory do
    %Dummy.Category{
      name: sequence(:name, &"name_#{&1}")
    }
  end

  def category_other_factory do
    %Dummy.CategoryColumn{
      name: sequence(:name, &"name_#{&1}")
    }
  end
end
