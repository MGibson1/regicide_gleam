import components/card_ui
import gleam/list
import gleam/option.{None, Some}
import gleam/set.{type Set}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import model.{type Msg}
import regicide/card.{type Card}
import regicide/game_state.{type GameState}

pub fn view_in_play(gs: GameState) -> Element(Msg) {
  html.div(
    [
      attribute.class("row-2 col-span-full flex w-full min-h-24 border-1 p-2"),
    ],
    [
      html.h2([], [html.text("in play")]),
      ..{ gs.in_play |> list.map(played_set(_, gs)) }
    ],
  )
}

fn played_set(cards: Set(Card), gs: GameState) -> Element(Msg) {
  card_stack_view(cards, gs)
}

fn card_stack_view(cards: Set(Card), gs: game_state.GameState) -> Element(Msg) {
  let cards = cards |> set.to_list

  let card_classes = case cards {
    [_, _] -> [
      Some(
        "absolute! top-0 group-hover:-translate-y-[20%] transition duration-150 ease-in-out",
      ),
      Some(
        "absolute! top-[35%] group-hover:translate-y-[20%] transition duration-150 ease-in-out",
      ),
    ]
    [_, _, _] -> [
      Some(
        "absolute! top-0 group-hover:-translate-y-[65%] transition duration-150 ease-in-out",
      ),
      Some("absolute! top-[17%] "),
      Some(
        "absolute! top-[35%] group-hover:translate-y-[65%] transition duration-150 ease-in-out",
      ),
    ]
    _ -> cards |> list.map(fn(_) { None })
  }

  let card_views =
    cards
    |> list.zip(card_classes)
    |> list.map(fn(x) {
      let #(card, classes) = x
      card_ui.view_card(card, gs, classes)
    })

  html.div([attribute.class("relative h-full w-[6.25rem] group")], card_views)
}
