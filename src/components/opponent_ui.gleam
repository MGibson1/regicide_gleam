import components/card_ui.{view_card}
import components/ui.{labeled_text}
import gleam/int
import gleam/list
import gleam/set
import lustre/attribute
import lustre/element
import lustre/element/html
import regicide/game_state.{type GameState}
import regicide/opponent
import regicide/turn

pub fn opponent_view(gs: GameState) {
  element.none()
}

pub fn opponent_card_view(gs: GameState) {
  html.div([attribute.class("flex flex-col justify-center h-full")], [
    view_card(gs.opponent |> opponent.card, gs),
  ])
}

pub fn opponent_stats_view(gs: GameState) {
  let selected_effect = gs |> game_state.selected_effect

  let curr_attack =
    opponent.attack(gs.opponent) - turn.defend(gs.in_play, gs.opponent)
  let next_attack = { gs.opponent |> opponent.attack } - selected_effect.shield

  let curr_health = gs.opponent |> opponent.health
  let next_health = curr_health - selected_effect.damage

  html.div([attribute.class("flex flex-col justify-center h-full")], [
    labeled_text(
      "health",
      curr_health |> int.to_string <> "(" <> next_health |> int.to_string <> ")",
    ),
    labeled_text(
      "attack",
      curr_attack |> int.to_string <> "(" <> next_attack |> int.to_string <> ")",
    ),
  ])
}
