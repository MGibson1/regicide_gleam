import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/set.{type Set}
import helpers
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

pub fn game_state_to_json(game_state: GameState) -> json.Json {
  let GameState(
    castle:,
    tavern:,
    discard:,
    opponent:,
    hand:,
    in_play:,
    redraws:,
    phase:,
  ) = game_state
  json.object([
    #("castle", json.array(castle, card.card_to_json)),
    #("tavern", json.array(tavern, card.card_to_json)),
    #("discard", json.array(discard, card.card_to_json)),
    #("opponent", opponent.opponent_to_json(opponent)),
    #("hand", card.card_set_to_json(hand)),
    #("in_play", json.array(in_play, card.card_set_to_json)),
    #("redraws", json.int(redraws)),
    #("phase", phase_to_json(phase)),
  ])
}

pub fn game_state_decoder() -> decode.Decoder(GameState) {
  use castle <- decode.field("castle", decode.list(card.card_decoder()))
  use tavern <- decode.field("tavern", decode.list(card.card_decoder()))
  use discard <- decode.field("discard", decode.list(card.card_decoder()))
  use opponent <- decode.field("opponent", opponent.opponent_decoder())
  use hand <- decode.field("hand", card.card_set_decoder())
  use in_play <- decode.field("in_play", decode.list(card.card_set_decoder()))
  use redraws <- decode.field("redraws", decode.int)
  use phase <- decode.field("phase", phase_decoder())
  decode.success(GameState(
    castle:,
    tavern:,
    discard:,
    opponent:,
    hand:,
    in_play:,
    redraws:,
    phase:,
  ))
}

pub type Phase {
  Attacking(with: Set(Card))
  Defending(with: Set(Card))
  Won
  Lost
}

fn phase_to_json(phase: Phase) -> json.Json {
  case phase {
    Attacking(with:) ->
      json.object([
        #("type", json.string("attacking")),
        #("with", card.card_set_to_json(with)),
      ])
    Defending(with:) ->
      json.object([
        #("type", json.string("defending")),
        #("with", card.card_set_to_json(with)),
      ])
    Won ->
      json.object([
        #("type", json.string("won")),
      ])
    Lost ->
      json.object([
        #("type", json.string("lost")),
      ])
  }
}

fn phase_decoder() -> decode.Decoder(Phase) {
  use variant <- decode.field("type", decode.string)
  case variant {
    "attacking" -> {
      use with <- decode.field("with", card.card_set_decoder())
      decode.success(Attacking(with:))
    }
    "defending" -> {
      use with <- decode.field("with", card.card_set_decoder())
      decode.success(Defending(with:))
    }
    "won" -> decode.success(Won)
    "lost" -> decode.success(Lost)
    _ -> decode.failure(Won, "Phase")
  }
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
    phase: Attacking(set.new()),
  )
}

pub fn discard_hand(gs: GameState) -> GameState {
  discard(gs, gs.hand)
}

pub fn discard(gs: GameState, cards: Set(Card)) -> GameState {
  case cards |> helpers.is_subset(gs.hand) {
    True -> Nil
    False -> panic as "cannot discard card not in hand"
  }

  let hand = gs.hand |> card.remove(cards)
  let discard = gs.discard |> list.append(cards |> set.to_list)
  let phase = case gs.phase {
    Attacking(with) -> Attacking(with |> card.safe_remove(cards))
    Defending(with) -> Defending(with |> card.safe_remove(cards))
    _ -> gs.phase
  }

  GameState(..gs, hand:, discard:, phase:)
}

pub fn draw(gs: GameState, count: Int) -> GameState {
  let max = max_hand_size - set.size(gs.hand)
  let draw = int.min(count, max)

  let #(add_to_hand, tavern) = gs.tavern |> card.draw_up_to(draw)
  let hand = gs.hand |> set.union(set.from_list(add_to_hand))

  GameState(..gs, tavern:, hand:)
}

pub fn heal(gs: GameState, count: Int) -> GameState {
  let #(drew, discard) = gs.discard |> list.shuffle |> card.draw_up_to(count)
  let tavern = gs.tavern |> list.append(drew)

  GameState(..gs, tavern:, discard:)
}

pub fn damage_opponent(gs: GameState, damage damage: Int) -> GameState {
  let opponent = gs.opponent |> opponent.damage(damage)
  GameState(..gs, opponent:)
}

pub fn opponent_attack_through_shield(gs: GameState) -> Int {
  let damage = gs.opponent |> opponent.attack
  let shield = turn.defend(gs.in_play, gs.opponent)
  int.max(0, damage - shield)
}

pub fn take_losses(gs: GameState, cards: Set(Card)) -> GameState {
  let power = cards |> card.total_power
  let gs = gs |> discard(cards)

  let next_gs = GameState(..gs, phase: Attacking(set.new()))

  case opponent_attack_through_shield(gs) - power <= 0 {
    True -> next_gs
    False -> GameState(..next_gs, phase: Lost)
  }
}

pub fn redraw(gs: GameState) -> GameState {
  case gs.redraws {
    n if n < 1 -> gs
    _ ->
      GameState(..gs, redraws: gs.redraws - 1)
      |> discard_hand
      |> draw(max_hand_size)
  }
}

pub fn discard_in_play(gs: GameState) -> GameState {
  let played_cards = gs.in_play |> list.map(set.to_list) |> list.flatten
  let discard = gs.discard |> list.append(played_cards)
  GameState(..gs, discard:, in_play: [])
}

fn draw_opponent(gs: GameState) -> GameState {
  let gs = gs |> discard_in_play

  let op_card = gs.opponent |> opponent.card
  let #(tavern, discard) = case gs.opponent |> opponent.health {
    n if n == 0 -> #([op_card, ..gs.tavern], gs.discard)
    _ -> #(gs.tavern, [op_card, ..gs.discard])
  }

  case gs.castle |> card.draw(1) {
    Ok(#([o], castle)) -> {
      GameState(
        ..gs,
        castle:,
        tavern:,
        discard:,
        opponent: opponent.from(o),
        phase: Attacking(set.new()),
      )
    }
    _ -> GameState(..gs, phase: Won)
  }
}

pub fn take_turn(gs: GameState) -> GameState {
  let gs = gs |> preview_turn

  case gs.opponent |> opponent.health {
    h if h > 0 -> gs
    _ -> draw_opponent(gs)
  }
}

pub fn preview_turn(gs: GameState) -> GameState {
  case gs.phase {
    Attacking(with) -> gs |> attack(with)
    Defending(with) -> gs |> take_losses(with)
    _ -> gs
  }
}

pub fn set_in_play(gs: GameState, cards: Set(Card)) {
  let hand = gs.hand |> card.remove(cards)
  let in_play = gs.in_play |> list.append([cards])
  GameState(..gs, in_play:, hand:)
}

pub fn attack(gs: GameState, with cards: Set(Card)) -> GameState {
  let effect = preview_effect(gs, cards)
  let gs = gs |> set_in_play(cards)

  // Heal
  let gs = heal(gs, effect.heal)

  // Draw
  let gs = draw(gs, effect.draw)

  // Damage
  let gs = damage_opponent(gs, effect.damage)

  // Shield happens during defending phase
  GameState(..gs, phase: Defending(set.new()))
}

pub fn preview_effect(gs: GameState, with cards: Set(Card)) -> Effect {
  cards |> turn.effect(gs.in_play, gs.opponent)
}

pub fn sufficient_losses(gs: GameState) -> Bool {
  case gs.phase {
    Defending(with) ->
      case take_losses(gs, with).phase {
        Lost -> False
        _ -> True
      }
    _ -> False
  }
}

pub fn selected(gs: GameState) -> Set(Card) {
  case gs.phase {
    Defending(sel) | Attacking(sel) -> sel
    _ -> set.new()
  }
}

pub fn toggle_selected(gs: GameState, card: Card) -> GameState {
  case gs.hand |> set.contains(card) {
    False -> panic as "cannot play a card not in hand"
    True -> Nil
  }

  let toggle = fn(prev: Set(Card), card: Card) -> Set(Card) {
    case prev |> set.contains(card) {
      True -> prev |> set.delete(card)
      False -> prev |> set.insert(card)
    }
  }

  let phase = case gs.phase {
    Attacking(prev) -> Attacking(with: prev |> toggle(card))
    Defending(prev) -> Defending(with: prev |> toggle(card))
    _ -> gs.phase
  }

  GameState(..gs, phase:)
}

pub fn is_selected(gs: GameState, card: Card) -> Bool {
  case gs.phase {
    Attacking(selected) | Defending(selected) -> selected |> set.contains(card)
    _ -> False
  }
}

pub fn can_select(gs: GameState, card: Card) -> Bool {
  case gs.phase {
    Attacking(selected) | Defending(selected) ->
      selected |> set.insert(card) |> turn.is_valid
    _ -> False
  }
}

pub fn selected_effect(gs: GameState) -> Effect {
  case gs.phase {
    Attacking(selected) -> turn.effect(selected, gs.in_play, gs.opponent)
    Defending(_) -> turn.effect(set.new(), gs.in_play, gs.opponent)
    _ -> turn.no_effect()
  }
}
