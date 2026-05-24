import components/card_ui.{view_card}
import gleam/bool
import gleam/list
import gleam/set
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import model.{type Msg}
import regicide/card.{type Card}
import regicide/game_state.{type GameState}

pub fn view_hand(gs: GameState) -> Element(Msg) {
  html.div([attribute.class("row-3 col-span-full min-h-24")], [
    html.h2([], [html.text("hand")]),
    html.div(
      [attribute.class("flex flex-wrap justify-center content-center")],
      { gs.hand |> set.to_list |> list.map(hand_card(_, gs)) },
    ),
  ])
}

fn hand_card(card: Card, gs: GameState) -> Element(Msg) {
  html.button(
    [
      attribute.disabled(
        !{
          case gs.phase {
            game_state.Attacking(_) -> gs |> game_state.can_select(card)
            game_state.Defending(_) -> {
              use <- bool.guard(gs |> game_state.is_selected(card), True)
              !{ gs |> game_state.sufficient_losses }
            }
            _ -> False
          }
        },
      ),
      event.on_click(model.UserClickedCardInHand(card)),
    ],
    [
      view_card(card, gs),
    ],
  )
}
