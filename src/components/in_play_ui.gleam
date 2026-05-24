import components/card_ui.{view_card}
import gleam/list
import gleam/set.{type Set}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import model.{type Msg}
import regicide/card.{type Card}
import regicide/game_state.{type GameState}

pub fn view_in_play(gs: GameState) -> Element(Msg) {
  html.div(
    [attribute.class("row-2 col-span-full flex w-full min-h-24 border-1 p-2")],
    [
      html.h2([], [html.text("in play")]),
      ..{ gs.in_play |> list.map(played_set(_, gs)) }
    ],
  )
}

fn played_set(cards: Set(Card), gs: GameState) -> Element(Msg) {
  html.div([], { cards |> set.to_list |> list.map(view_card(_, gs)) })
}
