import gleam/list
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import model.{type Msg}
import regicide/game_state.{type GameState}

pub fn joker_view(gs: GameState) -> Element(Msg) {
  html.button(
    [
      attribute.disabled(gs.redraws <= 0),
      event.on_click(model.UserClickedRedraw),
      attribute.class(""),
    ],
    [
      html.div([attribute.class("flex flex-row gap-3")], {
        fill(gs.redraws, html.div([], [html.text("Joker")]))
      }),
    ],
  )
}

fn fill(length l: Int, with v: a) -> List(a) {
  fill_loop(l, v, [])
}

fn fill_loop(l: Int, v: a, acc: List(a)) -> List(a) {
  case acc |> list.length {
    n if n == l -> acc
    n if n < l -> fill_loop(l, v, [v, ..acc])
    _ -> panic as "unreachable"
  }
}
