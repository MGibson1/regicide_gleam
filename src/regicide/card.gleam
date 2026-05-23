import gleam/int
import gleam/list
import gleam/order.{type Order}
import gleam/result

pub opaque type Card {
  Card(value: Value, suit: Suit)
}

pub fn card(value value: Value, suit suit: Suit) -> Card {
  case value {
    Num(i) if i > 10 -> panic as "illegal card value"
    _ -> Nil
  }
  Card(value:, suit:)
}

pub fn value(c: Card) -> Value {
  c.value
}

pub fn suit(c: Card) -> Suit {
  c.suit
}

pub type Value {
  Num(Int)
  Face(FaceType)
}

const sorted_values = [
  Num(1),
  Num(2),
  Num(3),
  Num(4),
  Num(5),
  Num(6),
  Num(7),
  Num(8),
  Num(9),
  Num(10),
  Face(Jack),
  Face(Queen),
  Face(King),
]

const sorted_suits = [Club, Draw, Heart, Shield]

pub type FaceType {
  King
  Queen
  Jack
}

pub type Suit {
  Shield
  Heart
  Draw
  Club
}

pub fn new_tavern() -> List(Card) {
  num_list_of(Heart)
  |> list.append(num_list_of(Club))
  |> list.append(num_list_of(Shield))
  |> list.append(num_list_of(Draw))
  |> list.shuffle
}

/// Returns a castle deck, with jacks, queens, kings in order
pub fn new_castle() -> List(Card) {
  list_of_face(Jack)
  |> list.append(list_of_face(Queen))
  |> list.append(list_of_face(King))
}

/// Returns randomized list of number cards for the given suit
fn num_list_of(suit: Suit) -> List(Card) {
  [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] |> list.map(num_from(_, suit)) |> list.shuffle
}

/// Returns randomized list of face cards for the given suit
fn list_of_face(face: FaceType) -> List(Card) {
  [Heart, Club, Shield, Draw] |> list.map(face_from(face, _)) |> list.shuffle
}

fn num_from(value: Int, suit: Suit) -> Card {
  Card(value: Num(value), suit:)
}

fn face_from(value: FaceType, suit: Suit) -> Card {
  Card(value: Face(value), suit:)
}

/// takes the top cards from the list, returning the two lists
/// as #(drawn, remaining)
///
/// Error if not enough cards in the list
pub fn draw(from l: List(a), take n: Int) -> Result(#(List(a), List(a)), Nil) {
  case l |> list.length {
    len if len >= n -> {
      Ok(#(list.take(l, n), list.drop(l, n)))
    }
    _ -> Error(Nil)
  }
}

///  sorts cards first by value, then by suit
pub fn sort_by_value(cards l: List(Card)) -> List(Card) {
  l |> sort_by([compare_by_value, compare_by_suite])
}

/// sorts cards first by suit, then by value
pub fn sort_by_suit(cards l: List(Card)) -> List(Card) {
  l |> sort_by([compare_by_suite, compare_by_value])
}

/// compares card values against the sorted standard
fn compare_by_value(a: Card, b: Card) -> Order {
  let assert Ok(a_idx) = sorted_values |> index_of(a.value)
  let assert Ok(b_idx) = sorted_values |> index_of(b.value)
  int.compare(a_idx, b_idx)
}

/// compares card suits agains the sorted standard
fn compare_by_suite(a: Card, b: Card) -> Order {
  let assert Ok(a_idx) = sorted_suits |> index_of(a.suit)
  let assert Ok(b_idx) = sorted_suits |> index_of(b.suit)
  int.compare(a_idx, b_idx)
}

fn index_of(list l: List(a), value v: a) -> Result(Int, Nil) {
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
fn sort_by(list l: List(a), by s: List(fn(a, a) -> Order)) -> List(a) {
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
