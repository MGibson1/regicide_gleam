import gleam/bool
import gleam/int
import gleam/list
import gleam/set.{type Set}
import regicide/card.{type Card}

pub type Effect {
  Effect(heal: Int, shield: Int, damage: Int, draw: Int)
}

pub fn effect(
  this_play s: Set(Card),
  prev_plays prev: List(Set(Card)),
) -> Effect {
  let power = s |> card.total_power

  // Hearts
  let heal = case s |> card.set_contains(card.Heart) {
    True -> power
    False -> 0
  }

  // Draw
  let draw = case s |> card.set_contains(card.Draw) {
    True -> power
    False -> 0
  }

  // Club
  let damage = case s |> card.set_contains(card.Club) {
    True -> 2 * power
    False -> power
  }

  // Shield
  let prev_shield =
    prev
    |> list.map(effect(_, []))
    |> list.map(fn(e) { e.shield })
    |> int.sum
  let shield = case s |> card.set_contains(card.Shield) {
    True -> power + prev_shield
    False -> prev_shield
  }

  Effect(heal:, shield:, damage:, draw:)
}

pub fn is_valid(cards s: Set(Card)) -> Bool {
  case s |> has_aces {
    True -> ace_play_valid(s)
    False -> combo_play_valid(s)
  }
}

fn ace_play_valid(cards s: Set(Card)) -> Bool {
  use <- bool.guard(set.size(s) > 2, False)

  s |> set.map(card.value) |> set.contains(card.Num(1))
}

fn combo_play_valid(s) {
  let values = s |> set.map(card.value)

  use <- bool.guard(set.size(values) != 1, False)

  let sum = s |> set.fold(0, fn(acc, c) { acc + card.attack_value(c) })
  sum <= 10
}

fn has_aces(s: Set(Card)) -> Bool {
  set.map(s, card.value) |> set.contains(card.Num(1))
}

pub fn defend(pre_plays prev: List(Set(Card))) -> Int {
  prev
  |> list.map(effect(_, []))
  |> list.map(fn(e) { e.shield })
  |> int.sum
}
