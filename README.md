# Ancestry

**The tree structure implementations for Ecto.**

## Table of contents

* [Getting started](#getting-started)
* [TODO](#todo)
* [Options for use Ancestry](#options-for-use-ancestry)
* [Examples](#examples)
* [Contributing](#contributing)
* [Make a pull request](#make-a-pull-request)
* [License](#license)
* [Credits](#credits)


## Getting started

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ancestry` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ancestry, "~> 0.1.0"}
  ]
end
```

Gen migration file to add string field in your model.

```shell
mix ecto.gen.migration add_ancestry_to_<model>
```

Add ancestry field and index to migration file.

```elixir
def change do
  alter table(:my_models) do
    add :ancestry, :string
  end
  create index(:my_models, [:ancestry])
end
```

```shell
mix ecto.migration
```

Add `use Ancestry, repo: MyApp.repo` to you model.ex

```elixir
defmodule MyModel do
  use Ecto.Schema
  use Ancestry, repo: MyApp.repo

  import Ecto.Changeset

  schema "my_models" do
    field :ancestry, :string
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:ancestry])
  end
end
```

## TODO

|  method           | return value | usage example | finished? |
|-------------------|--------------------------|---------------|-----------|
|`roots`            |all root node| `MyModel.roots` | `true` |
|`parent`           |parent of the record, nil for a root node| `MyModel.parent(record)` | `true` |
|`parent_id`        |parent id of the record, nil for a root node| `MyModel.parent_id(record)` | `true` |
|`has_parent?`      |true if the record has a parent, false otherwise| `MyModel.has_parent?(record)` | `true` |
|`root`             |root of the record's tree, self for a root node| `MyModel.root(record)` | `true` |
|`root_id`          |root id of the record's tree, self for a root node| `MyModel.root_id(record)` | `true` |
|`is_root?`         |  true if the record is a root node, false otherwise| `MyModel.is_root?(record)` | `true` |
|`ancestors`        |ancestors of the record, starting with the root and ending with the parent| `MyModel.ancestors(record)` | `true` |
|`ancestor_ids`     |ancestor ids of the record| `MyModel.ancestor_ids(record)` | `true` |
|`children`         |direct children of the record| `MyModel.children(record)` | `true` |
|`child_ids`        |direct children's ids| `MyModel.child_ids(record)`| `true` |
|`has_children?`    |true if the record has any children, false otherwise| `MyModel.has_children?(record)` | `true` |
|`is_childless?`    |true is the record has no children, false otherwise| `MyModel.is_childless?(record)` | `true` |
|`siblings`         |siblings of the record, the record itself is included*| `MyModel.siblings(record)` | `true` |
|`sibling_ids`      |sibling ids| `MyModel.sibling_ids(record)` | `true` |
|`has_siblings?`    |true if the record's parent has more than one child| `MyModel.has_siblings?(record)` | `true` |
|`is_only_child?`   |true if the record is the only child of its parent| `MyModel.is_only_child?(record)`| `true`|
|`descendants`      |direct and indirect children of the record| `MyModel.descendants(record)`| `true` |
|`descendant_ids`   |direct and indirect children's ids of the record| `MyModel.descendant_ids(record)` | `true` |
|`subtree`          |the model on descendants and itself| `MyModel.subtree(record)` | `true` |
|`subtree_ids`      |a list of all ids in the record's subtree| `MyModel.subtree_ids(record)`| `true` |
|`path`             |path of the record, starting with the root and ending with self| `MyModel.path(record)` | `false`|
|`path_ids`         |a list the path ids, starting with the root id and ending with the node's own id| `MyModel.path_ids(record)`| `false` |
|`depth`            |the depth of the node, root nodes are at depth 0| `MyModel.depth(record)`| `false` |

## Options for `use Ancestry`

The `use Ancestry` method supports the following options:

    :repo                  The current app repo
    :ancestry_column       Pass in a symbol to store ancestry in a different column
    :orphan_strategy       Instruct Ancestry what to do with children of a node that is destroyed:
                           :destroy   All children are destroyed as well (default)
                           :rootify   The children of the destroyed node become root nodes
                           :restrict  An AncestryException is raised if any children exist
                           :adopt     The orphan subtree is added to the parent of the deleted node.
                                      If the deleted node is Root, then rootify the orphan subtree.


## Examples


## Contributing

Bug report or pull request are welcome.

## Make a pull request

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Please write unit test with your code if necessary.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Credits

* [ancestry](https://github.com/stefankroes/ancestry) - Organise ActiveRecord model into a tree structure(Ruby classes).