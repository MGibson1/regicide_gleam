import components/card_ui.{view_card}
import components/ui.{labeled_text}
import gleam/int
import lustre/attribute
import lustre/element/html
import regicide/game_state.{type GameState}
import regicide/opponent

pub fn opponent_card_view(gs: GameState) {
  html.div([attribute.class("flex flex-col justify-center h-full")], [
    view_card(gs.opponent |> opponent.card, gs),
  ])
}

pub fn opponent_stats_view(gs: GameState) {
  let next_gs = gs |> game_state.preview_turn

  let health = fn(state: GameState) {
    state.opponent |> opponent.health |> int.to_string
  }
  let attack = fn(state: GameState) {
    state |> game_state.opponent_attack_through_shield |> int.to_string
  }

  html.div([attribute.class("flex flex-col justify-center h-full")], [
    labeled_text("health", gs |> health <> "(" <> next_gs |> health <> ")"),
    labeled_text("attack", gs |> attack <> "(" <> next_gs |> attack <> ")"),
  ])
}
