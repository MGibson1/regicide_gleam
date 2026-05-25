import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/order.{type Order}
import gleam/set.{type Set}
import regicide/list_helper.{index_of, sort_by}

pub opaque type Card {
  Card(value: Value, suit: Suit)
}

pub fn card_set_to_json(cards: Set(Card)) -> json.Json {
  json.array(cards |> set.to_list, card_to_json)
}

pub fn card_set_decoder() -> decode.Decoder(Set(Card)) {
  use value <- decode.then(decode.list(of: card_decoder()))
  decode.success(value |> set.from_list)
}

pub fn card_to_json(card: Card) -> json.Json {
  let Card(value:, suit:) = card
  json.object([
    #("value", value |> card_value_to_json),
    #("suit", suit |> suit_to_json),
  ])
}

pub fn card_decoder() -> decode.Decoder(Card) {
  use value <- decode.field("value", card_value_decoder())
  use suit <- decode.field("suit", suit_decoder())
  decode.success(Card(value:, suit:))
}

/// test function for creating cards
/// 
/// Not intended for production use, since invalid number values panic
@internal
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

pub fn attack_value(c: Card) -> Int {
  case c.value {
    Num(n) -> n
    Face(f) -> {
      case f {
        Jack -> 10
        Queen -> 15
        King -> 20
      }
    }
  }
}

pub fn total_power(cards: Set(Card)) -> Int {
  cards |> set.fold(0, fn(acc, c) { acc + attack_value(c) })
}

pub fn suit(c: Card) -> Suit {
  c.suit
}

pub type Value {
  Num(Int)
  Face(FaceType)
}

fn card_value_to_json(value: Value) -> json.Json {
  case value {
    Num(v) -> {
      json.object([#("type", json.string("num")), #("value", v |> json.int)])
    }
    Face(v) -> {
      json.object([
        #("type", json.string("face")),
        #("value", v |> face_type_to_json),
      ])
    }
  }
}

fn card_value_decoder() -> decode.Decoder(Value) {
  use variant <- decode.field("type", decode.string)

  case variant {
    "num" -> {
      use value <- decode.field("value", decode.int)
      decode.success(Num(value))
    }
    "face" -> {
      use value <- decode.field("value", face_type_decoder())
      decode.success(Face(value))
    }
    _ -> decode.failure(Num(1), "invalid value type")
  }
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

fn face_type_to_json(face_type: FaceType) -> json.Json {
  case face_type {
    King -> json.string("king")
    Queen -> json.string("queen")
    Jack -> json.string("jack")
  }
}

fn face_type_decoder() -> decode.Decoder(FaceType) {
  use variant <- decode.then(decode.string)
  case variant {
    "king" -> decode.success(King)
    "queen" -> decode.success(Queen)
    "jack" -> decode.success(Jack)
    _ -> decode.failure(King, "FaceType")
  }
}

pub type Suit {
  Shield
  Heart
  Draw
  Club
}

fn suit_to_json(suit: Suit) -> json.Json {
  case suit {
    Shield -> json.string("shield")
    Heart -> json.string("heart")
    Draw -> json.string("draw")
    Club -> json.string("club")
  }
}

fn suit_decoder() -> decode.Decoder(Suit) {
  use variant <- decode.then(decode.string)
  case variant {
    "shield" -> decode.success(Shield)
    "heart" -> decode.success(Heart)
    "draw" -> decode.success(Draw)
    "club" -> decode.success(Club)
    _ -> decode.failure(Shield, "Suit")
  }
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
  let #(drew, remaining) = draw_up_to(l, n)
  case drew |> list.length {
    count if count == n -> Ok(#(drew, remaining))
    _ -> Error(Nil)
  }
}

pub fn draw_up_to(from l: List(a), take n: Int) -> #(List(a), List(a)) {
  #(list.take(l, n), list.drop(l, n))
}

pub fn remove(from l: Set(a), take c: Set(a)) -> Set(a) {
  // cards not available
  case c |> set.is_subset(l) {
    True -> Nil
    False -> panic as "trying to remove cards that do not exist"
  }

  safe_remove(l, c)
}

pub fn safe_remove(from l: Set(a), take c: Set(a)) -> Set(a) {
  l |> set.difference(c)
}

pub fn set_contains(set cards: Set(Card), suit s: Suit) -> Bool {
  cards |> set.map(suit) |> set.contains(s)
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
