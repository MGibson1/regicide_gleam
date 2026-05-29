import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}

pub opaque type History(a) {
  History(points: List(a), current: Int)
}

pub fn history_to_json(
  history: History(a),
  encoder: fn(a) -> json.Json,
) -> json.Json {
  let History(points:, current:) = history
  json.object([
    #("points", json.array(points, encoder)),
    #("current", json.int(current)),
  ])
}

pub fn history_decoder(
  point_decoder: decode.Decoder(a),
) -> decode.Decoder(History(a)) {
  use points <- decode.field("points", decode.list(point_decoder))
  use current <- decode.field("current", decode.int)
  decode.success(History(points:, current:))
}

pub fn new(init: a) -> History(a) {
  History(points: [init], current: 0)
}

pub fn with(list l: List(a)) -> History(a) {
  History(points: l, current: list.length(l) - 1)
}

pub fn current(history hs: History(a)) -> a {
  case hs.points |> value_at(hs.current) {
    Ok(v) -> v
    Error(_) -> panic as "unreachable"
  }
}

pub fn current_index(history hs: History(a)) -> Int {
  hs.current
}

pub fn update(history: History(a), snapshot: a) -> History(a) {
  case length(history) {
    1 -> new(snapshot)
    _ -> history |> undo |> append(snapshot)
  }
}

pub fn append(history: History(a), snapshot: a) -> History(a) {
  let end_ordinal = length(history) - 1
  case history.current {
    n if n == end_ordinal -> {
      with(history.points |> list.append([snapshot]))
    }
    n if n < end_ordinal && n > -1 -> {
      history |> truncate(n) |> append(snapshot)
    }
    _ -> {
      new(snapshot)
    }
  }
}

pub fn has_prev(history hs: History(a)) -> Bool {
  hs.current > 0
}

pub fn prev(history hs: History(a)) -> Option(a) {
  case hs |> has_prev {
    True ->
      case hs.points |> value_at(hs.current - 1) {
        Ok(v) -> Some(v)
        Error(_) -> None
      }
    False -> None
  }
}

pub fn has_next(history hs: History(a)) -> Bool {
  hs.current < { list.length(hs.points) - 1 }
}

pub fn next(history hs: History(a)) -> Option(a) {
  case hs |> has_next {
    True ->
      case hs.points |> value_at(hs.current + 1) {
        Ok(v) -> Some(v)
        Error(_) -> None
      }
    False -> None
  }
}

pub fn undo(history hs: History(a)) -> History(a) {
  case hs |> has_prev {
    False -> hs
    True -> {
      History(..hs, current: hs.current - 1)
    }
  }
}

pub fn redo(history hs: History(a)) -> History(a) {
  case hs |> has_next {
    False -> hs
    True -> History(..hs, current: hs.current + 1)
  }
}

fn length(history: History(a)) -> Int {
  history.points |> list.length
}

fn truncate(history: History(a), location: Int) -> History(a) {
  let points = history.points |> truncate_list(location)
  with(points)
}

fn truncate_list(l: List(a), at: Int) -> List(a) {
  let #(truncated, _) = list.split(l, at + 1)
  truncated
}

fn value_at(l: List(a), index: Int) -> Result(a, Nil) {
  let length = list.length(l)
  case index {
    n if n < 0 -> Error(Nil)
    n if n >= length -> Error(Nil)
    _ -> {
      list.index_fold(l, Error(Nil), fn(acc, x, i) {
        case acc, i {
          Ok(_), _ -> acc
          Error(_), n if n == index -> {
            Ok(x)
          }
          _, _ -> acc
        }
      })
    }
  }
}
