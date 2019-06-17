# Ancestry

**Tree structure**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ancestry` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ancestry, "~> 0.1.0"}
  ]
end
```

## TODO

```
MyModel.parent(record)
MyModel.parent_id(record)
MyModel.has_parent?(record)

x MyModel.roots?
MyModel.root(record)
MyModel.root_id(record)
MyModel.is_root?(record)

x MyModel.ancestors(record)
x MyModel.ancestor_ids(record)

MyModel.path(record)
MyModel.path_ids(record)

x MyModel.children(record)
x MyModel.child_ids(record)
x MyModel.has_children?(record)

MyModel.is_childless?(record)

MyModel.siblings(record)
MyModel.sibling_ids(record)
MyModel.has_siblings?(record)

MyModel.is_only_child?(record)

MyModel.descendants(record)
MyModel.descendant_ids(record)

MyModel.subtree(record)
MyModel.subtree_ids(record)

MyModel.depth(record)
```
