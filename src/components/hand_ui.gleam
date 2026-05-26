import components/card_ui.{view_card}
import gleam/bool
import gleam/int
import gleam/list
import gleam/set
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import model.{type Msg, UserChangedSort}
import regicide/card.{type Card}
import regicide/game_state.{type GameState}
import regicide/toggle
import regicide/turn
import regicide/ui_state.{type UiState, BySuit, ByValue}

pub fn view_hand(gs: GameState, ui: UiState) -> Element(Msg) {
  let sorting_fn = case ui.sort {
    BySuit -> card.sort_by_suit
    ByValue -> card.sort_by_value
  }
  html.div([attribute.class("row-3 col-span-full min-h-24 flex flex-col")], [
    html.h2([], [html.text("hand")]),
    play_button(gs),
    html.div(
      [attribute.class("flex flex-wrap justify-center content-center")],
      {
        gs.hand
        |> set.to_list
        |> sorting_fn
        |> list.map(hand_card(_, gs))
      },
    ),
    html.div([attribute.class("self-end")], [
      toggle.toggle(
        "sort_by",
        #("Suit", UserChangedSort(BySuit)),
        #("Value", UserChangedSort(ByValue)),
        {
          case ui.sort {
            BySuit -> toggle.Left
            _ -> toggle.Right
          }
        },
      ),
    ]),
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

fn play_button(gs: GameState) -> Element(Msg) {
  case gs.phase {
    game_state.Attacking(with) -> {
      let selected_effect = with |> turn.effect([], gs.opponent)
      html.div(
        [attribute.class("grid grid-col-1 justify-center content-center")],
        [
          html.button([event.on_click(model.UserClickedPlayCards)], [
            html.text("Attack"),
          ]),
          html.text("resulting in " <> selected_effect |> turn.effect_to_string),
        ],
      )
    }
    game_state.Defending(with) -> {
      let selected_losses = with |> card.total_power
      let remaining =
        int.max(
          0,
          game_state.opponent_attack_through_shield(gs) - selected_losses,
        )
        |> int.to_string
      html.div(
        [attribute.class("grid grid-col-1 justify-center content-center")],
        [
          html.button(
            [
              attribute.disabled(!{ gs |> game_state.sufficient_losses }),
              event.on_click(model.UserClickedPlayCards),
            ],
            [
              html.text("Take Losses"),
            ],
          ),
          html.text("remaining: " <> remaining),
        ],
      )
    }
    _ -> element.none()
  }
}
