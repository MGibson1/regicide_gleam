import gleam/int
import gleam/list
import gleam/set
import gleeunit/should
import regicide/card
import regicide/constants
import regicide/game_state.{type GameState, GameState}
import regicide/opponent

pub fn new_game_test() {
  let GameState(
    castle:,
    opponent:,
    tavern:,
    discard:,
    hand:,
    in_play:,
    redraws:,
    phase:,
  ) = game_state.new()

  castle |> list.length |> should.equal(11)
  // first opponent is a jack
  opponent |> opponent.card |> card.value |> should.equal(card.Face(card.Jack))
  tavern |> list.length |> should.equal(32)
  discard |> should.equal([])
  hand |> set.size |> should.equal(8)
  in_play |> should.equal([])
  redraws |> should.equal(2)
  // game starts with player attacking
  phase |> should.equal(game_state.Attacking(set.new()))

  castle
  |> list.map(card.value)
  |> should.equal([
    card.Face(card.Jack),
    card.Face(card.Jack),
    card.Face(card.Jack),
    card.Face(card.Queen),
    card.Face(card.Queen),
    card.Face(card.Queen),
    card.Face(card.Queen),
    card.Face(card.King),
    card.Face(card.King),
    card.Face(card.King),
    card.Face(card.King),
  ])
  [opponent |> opponent.card] |> intersection(with: castle) |> should.equal([])
  hand |> set.to_list |> intersection(with: tavern) |> should.equal([])
}

fn intersection(l1: List(a), with l2: List(a)) -> List(a) {
  l1 |> set.from_list |> set.intersection(set.from_list(l2)) |> set.to_list
}

fn random_game_state() -> GameState {
  let gs = game_state.new()
  let assert Ok(#(in_tavern, castle)) =
    card.new_castle() |> card.draw(int.random(12))
  let assert Ok(#([o], castle)) = castle |> card.draw(1)
  let gs =
    GameState(
      ..gs,
      castle:,
      opponent: o |> opponent.from,
      tavern: gs.tavern |> list.append(in_tavern) |> list.shuffle,
    )

  let hand_size = int.random(constants.max_hand_size + 1)
  let #(in_hand, tavern) = gs.tavern |> card.draw_up_to(hand_size)
  let gs = GameState(..gs, tavern:, hand: in_hand |> set.from_list)

  let tavern_size = gs.tavern |> list.length
  let #(discard, tavern) = gs.tavern |> card.draw_up_to(int.random(tavern_size))
  let gs = GameState(..gs, tavern:, discard:)

  // not going to worry about valid plays right now
  let tavern_size = gs.tavern |> list.length
  let #(in_play_cards, tavern) =
    gs.tavern |> card.draw_up_to(int.random(tavern_size))
  GameState(
    ..gs,
    tavern:,
    in_play: [in_play_cards |> set.from_list],
    redraws: 2,
  )
}

pub fn apply_heal_test() {
  let gs = random_game_state()
  let result =
    gs
    |> game_state.heal(1)

  case gs.discard |> list.length {
    0 -> result |> should.equal(gs)
    _ -> {
      // moved one card from discard to tavern
      result.tavern
      |> set.from_list
      |> set.intersection(set.from_list(result.discard))
      |> should.equal(set.new())
      result.tavern
      |> set.from_list
      |> set.intersection(set.from_list(gs.discard))
      |> set.size
      |> should.equal(1)
    }
  }
}

pub fn apply_over_heal_test() {
  let gs = random_game_state()
  let result =
    gs
    |> game_state.heal(100)

  case gs.discard |> list.length {
    0 -> result |> should.equal(gs)
    _ -> {
      let expected_move = gs.discard |> list.length
      // moved one card from discard to tavern
      result.tavern
      |> set.from_list
      |> set.intersection(set.from_list(result.discard))
      |> should.equal(set.new())
      result.tavern
      |> set.from_list
      |> set.intersection(set.from_list(gs.discard))
      |> set.size
      |> should.equal(expected_move)
    }
  }
}

// TODO: gs equality is flaky due to set equivalence being ordered
pub fn attempt_to_draw_over_max_hand_size_test() {
  let gs = random_game_state()
  let result =
    gs
    |> game_state.draw(10)

  case gs.hand |> set.size {
    8 -> result |> should.equal(gs)
    _ -> {
      let expected_move =
        int.min(
          constants.max_hand_size - set.size(gs.hand),
          gs.tavern |> list.length,
        )

      result.hand
      |> set.intersection(set.from_list(result.tavern))
      |> should.equal(set.new())

      result.hand
      |> set.intersection(set.from_list(gs.tavern))
      |> set.size
      |> should.equal(expected_move)
    }
  }
}

pub fn apply_draw_test() {
  let gs = random_game_state()
  let result =
    gs
    |> game_state.draw(1)

  case gs.hand |> set.size {
    8 -> result |> should.equal(gs)
    _ -> {
      result.hand
      |> set.intersection(set.from_list(result.tavern))
      |> should.equal(set.new())

      result.hand
      |> set.intersection(set.from_list(gs.tavern))
      |> set.size
      |> should.equal(1)
    }
  }
}

pub fn damage_opponent_test() {
  let gs = random_game_state()

  let original_health = gs.opponent |> opponent.health

  let damage = int.random(100)
  let result =
    gs
    |> game_state.damage_opponent(damage)

  result.opponent |> opponent.health |> should.equal(original_health - damage)
}
