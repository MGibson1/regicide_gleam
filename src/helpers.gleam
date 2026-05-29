import gleam/set.{type Set}

pub fn is_subset(first: Set(a), second: Set(a)) -> Bool {
  { set.difference(first, second) |> set.size } == 0
}
