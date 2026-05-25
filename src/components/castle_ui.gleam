import gleam/list
import gleam/string
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import model.{type Msg}
import regicide/card
import regicide/game_state.{type GameState}

pub fn castle_view(gs: GameState) -> Element(Msg) {
  html.div([attribute.class("flex flex-row gap-3 place-center")], {
    gs.castle
    |> list.map(fn(c) {
      html.div([], [html.text(c |> card.value_string |> first_letter)])
    })
  })
}

fn first_letter(s: String) -> String {
  case s |> string.first {
    Ok(l) -> l
    Error(_) -> ""
  }
}
