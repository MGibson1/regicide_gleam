import components/ui.{labeled_text}
import gleam/int
import gleam/list
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import model.{type Msg}
import regicide/card.{type Card, Face, Jack, King, Num, Queen}
import regicide/game_state

pub fn face_down_pile(
  label: String,
  cards: List(Card),
  next: List(Card),
) -> Element(Msg) {
  let len = fn(l: List(a)) { l |> list.length |> int.to_string }
  html.div([attribute.class("self-start")], [
    labeled_text(label, cards |> len <> "(" <> next |> len <> ")"),
  ])
}

pub fn view_card(card: Card, gs: game_state.GameState) -> Element(Msg) {
  html.div(
    [
      attribute.class(
        "border-1 m-2 p-2 w-min flex flex-col justify-center content-center",
      ),
      attribute.classes([#("border-3", gs |> game_state.is_selected(card))]),
    ],
    [
      labeled_text("suit", card |> suit_string),
      labeled_text("value", card |> value_string),
    ],
  )
}
