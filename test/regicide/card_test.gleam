import gleeunit/should
import regicide/card.{
  Club, Draw, Face, Heart, Jack, King, Num, Queen, Shield, card,
}

pub fn draw_test() {
  [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  |> card.draw(3)
  |> should.equal(Ok(#([1, 2, 3], [4, 5, 6, 7, 8, 9, 10])))
}

pub fn draw_not_enough_test() {
  [1, 2] |> card.draw(5) |> should.be_error
}

pub fn sort_by_suit_test() {
  [
    card(value: Num(10), suit: Shield),
    card(value: Num(1), suit: Shield),
    card(value: Num(1), suit: Heart),
    card(value: Num(1), suit: Draw),
    card(value: Num(1), suit: Club),
  ]
  |> card.sort_by_suit
  |> should.equal([
    card(value: Num(1), suit: Club),
    card(value: Num(1), suit: Draw),
    card(value: Num(1), suit: Heart),
    card(value: Num(1), suit: Shield),
    card(value: Num(10), suit: Shield),
  ])
}

pub fn sort_by_value_test() {
  [
    card(value: Face(King), suit: Club),
    card(value: Face(Queen), suit: Club),
    card(value: Face(Jack), suit: Club),
    card(value: Num(10), suit: Club),
    card(value: Num(9), suit: Club),
    card(value: Num(7), suit: Heart),
    card(value: Num(8), suit: Club),
    card(value: Num(7), suit: Club),
    card(value: Num(6), suit: Club),
    card(value: Num(5), suit: Club),
    card(value: Num(4), suit: Club),
    card(value: Num(3), suit: Club),
    card(value: Num(2), suit: Club),
    card(value: Num(1), suit: Club),
  ]
  |> card.sort_by_value
  |> should.equal([
    card(value: Num(1), suit: Club),
    card(value: Num(2), suit: Club),
    card(value: Num(3), suit: Club),
    card(value: Num(4), suit: Club),
    card(value: Num(5), suit: Club),
    card(value: Num(6), suit: Club),
    card(value: Num(7), suit: Club),
    card(value: Num(7), suit: Heart),
    card(value: Num(8), suit: Club),
    card(value: Num(9), suit: Club),
    card(value: Num(10), suit: Club),
    card(value: Face(Jack), suit: Club),
    card(value: Face(Queen), suit: Club),
    card(value: Face(King), suit: Club),
  ])
}
