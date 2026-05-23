import regicide/card.{type Card}
import regicide/constants.{max_hand_size}

pub type GameState {
  GameState(
    castle: List(Card),
    tavern: List(Card),
    discard: List(Card),
    opponent: Card,
    hand: List(Card),
    redraws: Int,
  )
}

pub fn new() -> GameState {
  let assert Ok(#(hand, tavern)) = card.new_tavern() |> card.draw(max_hand_size)
  let assert Ok(#([opponent], castle)) = card.new_castle() |> card.draw(1)
  GameState(castle:, opponent:, tavern:, discard: [], hand:, redraws: 2)
}
