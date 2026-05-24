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
  Attacking(with: Set(Card))
  Defending(with: Set(Card))
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
    phase: Attacking(set.new()),
  )
}

pub fn discard_hand(gs: GameState) -> GameState {
  GameState(
    ..gs,
    discard: gs.discard |> list.append(gs.hand |> set.to_list) |> list.shuffle,
    hand: set.from_list([]),
  )
}

pub fn discard(gs: GameState, cards: Set(Card)) -> GameState {
  case cards |> set.is_subset(gs.hand) {
    True -> Nil
    False -> panic as "cannod discard card not in hand"
  }

  let hand = gs.hand |> card.remove(cards)
  let discard = gs.discard |> list.append(cards |> set.to_list)

  GameState(..gs, hand:, discard:)
}

pub fn redraw(gs: GameState) -> GameState {
  case gs.redraws {
    n if n < 1 -> gs
    _ ->
      GameState(..gs, redraws: gs.redraws - 1)
      |> discard_hand
      |> apply_draw(max_hand_size)
  }
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
      GameState(
        ..gs,
        castle:,
        opponent: opponent.from(o),
        phase: Attacking(set.new()),
      )
    }
    _ -> GameState(..gs, phase: Won)
  }
}

pub fn take_turn(gs: GameState) -> GameState {
  case gs.phase {
    Attacking(with) -> gs |> attack(with) |> set_in_play(with)
    Defending(with) -> gs |> take_losses(with)
    _ -> gs
  }
}

pub fn set_in_play(gs: GameState, cards: Set(Card)) {
  GameState(..gs, in_play: gs.in_play |> list.append([cards]))
}

pub fn attack(gs: GameState, with cards: Set(Card)) -> GameState {
  let effect = cards |> turn.effect(gs.in_play, gs.opponent)
  let gs = gs |> discard(cards)

  // Heal
  let gs = apply_heal(gs, effect.heal)

  // Draw
  let gs = apply_draw(gs, effect.draw)

  // Damage
  let gs = apply_damage(gs, effect.damage)

  // Shield happens during defending phase
  let gs = GameState(..gs, phase: Defending(set.new()))

  case gs.opponent |> opponent.health {
    h if h > 0 -> gs
    _ -> draw_opponent(gs)
  }
}

pub fn apply_heal(gs: GameState, heal heal: Int) -> GameState {
  let #(drew, discard) = gs.discard |> list.shuffle |> card.draw_up_to(heal)
  let tavern = gs.tavern |> list.append(drew)

  GameState(..gs, tavern:, discard:)
}

pub fn apply_draw(gs: GameState, draw draw: Int) -> GameState {
  let max_draw = int.min(max_hand_size - set.size(gs.hand), draw)
  let #(add_to_hand, tavern) = gs.tavern |> card.draw_up_to(max_draw)
  let hand = gs.hand |> set.to_list |> list.append(add_to_hand) |> set.from_list

  GameState(..gs, hand:, tavern:)
}

pub fn apply_damage(gs: GameState, damage damage: Int) -> GameState {
  let opponent = gs.opponent |> opponent.damage(damage)
  GameState(..gs, opponent:)
}

pub fn take_losses(gs: GameState, cards: Set(Card)) -> GameState {
  let power = cards |> card.total_power
  let gs = gs |> discard(cards)

  let damage = gs.opponent |> opponent.attack
  let shield = turn.defend(gs.in_play, gs.opponent)

  let next_gs = GameState(..gs, phase: Attacking(set.new()))

  case damage - shield - power <= 0 {
    True -> next_gs
    False -> GameState(..next_gs, phase: Lost)
  }
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
