import gleam/list
import gleeunit/should
import regicide/card
import regicide/game_state.{GameState}

pub fn new_game_test() {
  let GameState(castle:, opponent:, tavern:, discard:, hand:, redraws:) =
    game_state.new()

  castle |> list.length |> should.equal(11)
  opponent |> card.value |> should.equal(card.Face(card.Jack))
  tavern |> list.length |> should.equal(32)
  discard |> should.equal([])
  hand |> list.length |> should.equal(8)
  redraws |> should.equal(2)

  [opponent] |> intersection(with: castle) |> should.equal([])
  hand |> intersection(with: tavern) |> should.equal([])
}

fn intersection(l: List(a), with m: List(a)) -> List(a) {
  list.fold(l, [], fn(agg, i) {
    case m |> list.contains(i) {
      True -> agg |> list.append([i])
      False -> agg
    }
  })
}
