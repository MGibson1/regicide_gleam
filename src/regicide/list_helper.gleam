import gleam/list
import gleam/order.{type Order}
import gleam/result

pub fn index_of(list l: List(a), value v: a) -> Result(Int, Nil) {
  list.index_map(l, fn(x, i) { #(i, x) })
  |> list.find(fn(index_value) {
    let #(_, x) = index_value
    x == v
  })
  |> result.map(fn(index_value) {
    let #(i, _) = index_value
    i
  })
}

/// Sorts a list by multiple sorting functions, applying each successive
/// sort function as a tie-breaker on equalities.
pub fn sort_by(list l: List(a), by s: List(fn(a, a) -> Order)) -> List(a) {
  sort_by_loop([l], s) |> list.flatten
}

fn sort_by_loop(
  list l: List(List(a)),
  by s: List(fn(a, a) -> Order),
) -> List(List(a)) {
  case s {
    [] -> l
    [s, ..rest] -> {
      sort_by_loop(l |> list.map(sort_group_equal(_, s)) |> list.flatten, rest)
    }
  }
}

fn sort_group_equal(l: List(a), sort: fn(a, a) -> Order) -> List(List(a)) {
  l |> list.sort(sort) |> sort_group_equal_inner(sort, [])
}

fn sort_group_equal_inner(
  l: List(a),
  sort: fn(a, a) -> Order,
  acc: List(List(a)),
) -> List(List(a)) {
  let accumulate_with_prev = fn(x) {
    case list.last(acc) {
      Error(_) -> [[x]]
      Ok(prev) -> {
        let assert [pick] = list.take(prev, 1)
        case sort(pick, x) {
          order.Lt -> acc |> list.append([[x]])
          order.Gt -> panic as "input list not sorted"
          order.Eq -> {
            acc |> list.take(list.length(acc) - 1) |> list.append([[x, ..prev]])
          }
        }
      }
    }
  }
  case l {
    [] -> acc
    [x] -> accumulate_with_prev(x)
    [x, ..rest] -> {
      let acc = accumulate_with_prev(x)
      sort_group_equal_inner(rest, sort, acc)
    }
  }
}
