import components/card_ui
import lustre/element.{type Element}
import model.{type Msg}
import regicide/game_state.{type GameState}

pub fn discard_view(gs: GameState) -> Element(Msg) {
  let next_gs = gs |> game_state.preview_turn
  card_ui.face_down_pile("Discard", gs.discard, next_gs.discard)
}
