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

|  method           | return value | usage example | finished? |
|-------------------|--------------------------|---------------|-----------|
|`roots`            |return all root node.| `MyModel.roots` | `true` |
|`parent`           |parent of the record, nil for a root node| `MyModel.parent(record)` | `true` |
|`parent_id`        |parent id of the record, nil for a root node| `MyModel.parent_id(record)` | `true` |
|`has_parent?`      |true if the record has a parent, false otherwise| `MyModel.has_parent?(record)` | `true` |
|`root`             |root of the record's tree, self for a root node| `MyModel.root(record)` | `true` |
|`root_id`          |root id of the record's tree, self for a root node| `MyModel.root_id(record)` | `true` |
|`is_root?`         |  true if the record is a root node, false otherwise| `MyModel.is_root?(record)` | `true` |
|`ancestors`        |ancestors of the record, starting with the root and ending with the parent| `MyModel.ancestors(record)` | `true` |
|`ancestor_ids`     |ancestor ids of the record| `MyModel.ancestor_ids(record)` | `true` |
|`path`             |path of the record, starting with the root and ending with self| `MyModel.path(record)` | `false`|
|`path_ids`         |a list the path ids, starting with the root id and ending with the node's own id| `MyModel.path_ids(record)`| `false` |
|`children`         |direct children of the record| `MyModel.children(record)` | `true` |
|`child_ids`        |direct children's ids| `MyModel.child_ids(record)`| `true` |
|`has_children?`    |true if the record has any children, false otherwise| `MyModel.has_children?(record)` | `true` |
|`is_childless?`    |true is the record has no children, false otherwise| `MyModel.is_childless?(record)` | `false` |
|`siblings`         |siblings of the record, the record itself is included*| `MyModel.siblings(record)` | `false` |
|`sibling_ids`      |sibling ids| `MyModel.sibling_ids(record)` | `false` |
|`has_siblings?`    |true if the record's parent has more than one child| `MyModel.has_siblings?(record)` | `false` |
|`is_only_child?`   |true if the record is the only child of its parent| `MyModel.is_only_child?(record)`| `false`|
|`descendants`      |direct and indirect children of the record| `MyModel.descendants(record)`| `false` |
|`descendant_ids`   |direct and indirect children's ids of the record| `MyModel.descendant_ids(record)` | `false` |
|`indirects`        |indirect children of the record| | |
|`indirect_ids`     |indirect children's ids of the record| | |
|`subtree`          |the model on descendants and itself| `MyModel.subtree(record)` | `false`|
|`subtree_ids`      |a list of all ids in the record's subtree| `MyModel.subtree_ids(record)`|`false` |
|`depth`            |the depth of the node, root nodes are at depth 0| `MyModel.depth(record)`| [ ] |
