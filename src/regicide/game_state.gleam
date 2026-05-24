import gleam/int
import gleam/list
import gleam/set.{type Set}
import regicide/card.{type Card}
import regicide/constants.{max_hand_size}
import regicide/opponent.{type Opponent}
import regicide/turn.{type Effect}

pub type GameState {
  GameState(
    castle: List(Card),
    tavern: List(Card),
    discard: List(Card),
    opponent: Opponent,
    hand: Set(Card),
    in_play: List(Set(Card)),
    redraws: Int,
    phase: Phase,
  )
}

pub type Phase {
  Attacking
  Defending
  Won
  Lost
}

pub fn new() -> GameState {
  let assert Ok(#(hand, tavern)) = card.new_tavern() |> card.draw(max_hand_size)
  let assert Ok(#([opponent], castle)) = card.new_castle() |> card.draw(1)
  GameState(
    castle:,
    opponent: opponent.from(opponent),
    tavern:,
    discard: [],
    hand: set.from_list(hand),
    in_play: [],
    redraws: 2,
    phase: Attacking,
  )
}

pub fn discard_hand(gs: GameState) -> GameState {
  GameState(
    ..gs,
    discard: gs.discard |> list.append(gs.hand |> set.to_list) |> list.shuffle,
    hand: set.from_list([]),
  )
}

pub fn discard_in_play(gs: GameState) -> GameState {
  let played_cards = gs.in_play |> list.map(set.to_list) |> list.flatten
  let discard = gs.discard |> list.append(played_cards)
  GameState(..gs, discard:, in_play: [])
}

fn draw_opponent(gs: GameState) -> GameState {
  let gs = gs |> discard_in_play

  case gs.castle |> card.draw(1) {
    Ok(#([o], castle)) -> {
      GameState(..gs, castle:, opponent: opponent.from(o), phase: Attacking)
    }
    _ -> GameState(..gs, phase: Won)
  }
}

pub fn attack_with(gs: GameState, play: Set(Card)) -> GameState {
  let #(gs, effect) = play_cards(gs, play)

  // Heal
  let gs = apply_heal(gs, effect)

  // Draw
  let gs = apply_draw(gs, effect)

  // Damage
  let gs = apply_damage(gs, effect)

  // Shield happens during defending phase
  let gs = GameState(..gs, phase: Defending)

  case gs.opponent |> opponent.health {
    h if h > 0 -> gs
    _ -> draw_opponent(gs)
  }
}

pub fn play_cards(gs: GameState, play: Set(Card)) -> #(GameState, Effect) {
  let hand = gs.hand |> card.remove(play)
  let effect = turn.effect(play, gs.in_play)

  #(GameState(..gs, hand:, in_play: gs.in_play |> list.append([play])), effect)
}

pub fn apply_heal(gs: GameState, effect: Effect) -> GameState {
  let #(drew, discard) =
    gs.discard |> list.shuffle |> card.draw_up_to(effect.heal)
  let tavern = gs.tavern |> list.append(drew)

  GameState(..gs, tavern:, discard:)
}

pub fn apply_draw(gs: GameState, effect: Effect) -> GameState {
  let max_draw = int.min(max_hand_size - set.size(gs.hand), effect.draw)
  let #(add_to_hand, tavern) = gs.tavern |> card.draw_up_to(max_draw)
  let hand = gs.hand |> set.to_list |> list.append(add_to_hand) |> set.from_list

  GameState(..gs, hand:, tavern:)
}

pub fn apply_damage(gs: GameState, effect: Effect) -> GameState {
  let opponent = gs.opponent |> opponent.damage(effect.damage)
  GameState(..gs, opponent:)
}

pub fn take_damage(gs: GameState, play: Set(Card)) -> GameState {
  let power = play |> card.total_power
  let hand = gs.hand |> card.remove(play)
  let discard = gs.discard |> list.append(play |> set.to_list)

  let damage = gs.opponent |> opponent.attack
  let shield = turn.defend(gs.in_play)

  let next_gs = GameState(..gs, hand:, discard:, phase: Attacking)

  case damage - shield - power <= 0 {
    True -> next_gs
    False -> GameState(..next_gs, phase: Lost)
  }
}

pub fn sufficient_losses(gs: GameState, play: Set(Card)) -> Bool {
  case take_damage(gs, play).phase {
    Lost -> False
    _ -> True
  }
}
