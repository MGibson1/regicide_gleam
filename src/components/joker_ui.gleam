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
      html.text("Joker"),
      html.text("Joker"),
    ],
  )
}
