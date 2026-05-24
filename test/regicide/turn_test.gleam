import gleam/set
import gleeunit/should
import regicide/card
import regicide/turn

pub fn valid_single_test() {
  let play = [card.card(card.Num(7), card.Club)] |> set.from_list
  turn.is_valid(play) |> should.be_true
}

pub fn valid_ace_test() {
  let play = [card.card(card.Num(1), card.Club)] |> set.from_list
  turn.is_valid(play) |> should.be_true
}

pub fn valid_two_aces_test() {
  let play =
    [card.card(card.Num(1), card.Club), card.card(card.Num(1), card.Heart)]
    |> set.from_list
  turn.is_valid(play) |> should.be_true
}

pub fn invalid_three_aces_test() {
  let play =
    [
      card.card(card.Num(1), card.Club),
      card.card(card.Num(1), card.Heart),
      card.card(card.Num(1), card.Draw),
    ]
    |> set.from_list
  turn.is_valid(play) |> should.be_false
}

pub fn invalid_three_combo_with_ace_test() {
  let play =
    [
      card.card(card.Num(7), card.Club),
      card.card(card.Num(7), card.Heart),
      card.card(card.Num(1), card.Draw),
    ]
    |> set.from_list
  turn.is_valid(play) |> should.be_false
}

pub fn valid_four_of_a_kind_test() {
  let play =
    [
      card.card(card.Num(2), card.Club),
      card.card(card.Num(2), card.Heart),
      card.card(card.Num(2), card.Draw),
      card.card(card.Num(2), card.Draw),
    ]
    |> set.from_list
  turn.is_valid(play) |> should.be_true
}

pub fn valid_three_of_a_kind_test() {
  let play =
    [
      card.card(card.Num(2), card.Heart),
      card.card(card.Num(2), card.Draw),
      card.card(card.Num(2), card.Draw),
    ]
    |> set.from_list
  turn.is_valid(play) |> should.be_true

  let play =
    [
      card.card(card.Num(3), card.Heart),
      card.card(card.Num(3), card.Draw),
      card.card(card.Num(3), card.Draw),
    ]
    |> set.from_list
  turn.is_valid(play) |> should.be_true
}

pub fn valid_two_of_a_kind_test() {
  let play =
    [
      card.card(card.Num(2), card.Heart),
      card.card(card.Num(2), card.Draw),
    ]
    |> set.from_list
  turn.is_valid(play) |> should.be_true

  let play =
    [
      card.card(card.Num(3), card.Draw),
      card.card(card.Num(3), card.Draw),
    ]
    |> set.from_list
  turn.is_valid(play) |> should.be_true

  let play =
    [
      card.card(card.Num(4), card.Draw),
      card.card(card.Num(4), card.Draw),
    ]
    |> set.from_list
  turn.is_valid(play) |> should.be_true

  let play =
    [
      card.card(card.Num(5), card.Draw),
      card.card(card.Num(5), card.Draw),
    ]
    |> set.from_list
  turn.is_valid(play) |> should.be_true
}

pub fn effect_of_card_test() {
  // Heart
  [card.card(card.Num(3), card.Heart)]
  |> set.from_list
  |> turn.effect([])
  |> should.equal(turn.Effect(heal: 3, shield: 0, damage: 3, draw: 0))
  // Club
  [card.card(card.Num(3), card.Club)]
  |> set.from_list
  |> turn.effect([])
  |> should.equal(turn.Effect(heal: 0, shield: 0, damage: 6, draw: 0))
  // Shield
  [card.card(card.Num(3), card.Shield)]
  |> set.from_list
  |> turn.effect([])
  |> should.equal(turn.Effect(heal: 0, shield: 3, damage: 3, draw: 0))
  // Draw
  [card.card(card.Num(3), card.Draw)]
  |> set.from_list
  |> turn.effect([])
  |> should.equal(turn.Effect(heal: 0, shield: 0, damage: 3, draw: 3))
}

pub fn effect_of_ace_test() {
  // Heart
  [card.card(card.Num(3), card.Heart), card.card(card.Num(1), card.Heart)]
  |> set.from_list
  |> turn.effect([])
  |> should.equal(turn.Effect(heal: 4, shield: 0, damage: 4, draw: 0))
  // Club
  [card.card(card.Num(3), card.Heart), card.card(card.Num(1), card.Club)]
  |> set.from_list
  |> turn.effect([])
  |> should.equal(turn.Effect(heal: 4, shield: 0, damage: 8, draw: 0))
  // Shield
  [card.card(card.Num(3), card.Heart), card.card(card.Num(1), card.Shield)]
  |> set.from_list
  |> turn.effect([])
  |> should.equal(turn.Effect(heal: 4, shield: 4, damage: 4, draw: 0))
  // Draw
  [card.card(card.Num(3), card.Heart), card.card(card.Num(1), card.Draw)]
  |> set.from_list
  |> turn.effect([])
  |> should.equal(turn.Effect(heal: 4, shield: 0, damage: 4, draw: 4))
}

pub fn effect_of_heart_ace_test() {
  [card.card(card.Num(3), card.Draw), card.card(card.Num(1), card.Shield)]
  |> set.from_list
  |> turn.effect([])
  |> should.equal(turn.Effect(heal: 0, shield: 4, damage: 4, draw: 4))
}

pub fn effect_of_a_combo_test() {
  // Club
  [card.card(card.Num(3), card.Heart), card.card(card.Num(3), card.Club)]
  |> set.from_list
  |> turn.effect([])
  |> should.equal(turn.Effect(heal: 6, shield: 0, damage: 12, draw: 0))
  // Shield
  [card.card(card.Num(3), card.Heart), card.card(card.Num(3), card.Shield)]
  |> set.from_list
  |> turn.effect([])
  |> should.equal(turn.Effect(heal: 6, shield: 6, damage: 6, draw: 0))
  // Draw
  [card.card(card.Num(3), card.Heart), card.card(card.Num(3), card.Draw)]
  |> set.from_list
  |> turn.effect([])
  |> should.equal(turn.Effect(heal: 6, shield: 0, damage: 6, draw: 6))
  // Club and Shield
  [
    card.card(card.Num(3), card.Heart),
    card.card(card.Num(3), card.Club),
    card.card(card.Num(3), card.Shield),
  ]
  |> set.from_list
  |> turn.effect([])
  |> should.equal(turn.Effect(heal: 9, shield: 9, damage: 18, draw: 0))
}

pub fn effect_of_previous_play_test() {
  let prev = [
    [
      card.card(card.Num(3), card.Heart),
      card.card(card.Num(3), card.Club),
      card.card(card.Num(3), card.Shield),
    ]
      |> set.from_list,
    [card.card(card.Num(3), card.Heart), card.card(card.Num(3), card.Shield)]
      |> set.from_list,
  ]
  [card.card(card.Face(card.King), card.Draw)]
  |> set.from_list
  |> turn.effect(prev)
  |> should.equal(turn.Effect(heal: 0, shield: 15, damage: 20, draw: 20))
}
