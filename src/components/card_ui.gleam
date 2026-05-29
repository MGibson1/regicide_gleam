import components/ui.{labeled_text}
import gleam/int
import gleam/list
import gleam/option.{type Option}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import model.{type Msg}
import regicide/card.{type Card}
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

pub fn view_card(
  card: Card,
  gs: game_state.GameState,
  additional_classes: Option(String),
) -> Element(Msg) {
  card_internal(card, gs |> game_state.is_selected(card), additional_classes)
}

fn card_internal(
  card: Card,
  selected: Bool,
  additional_classes: Option(String),
) -> Element(Msg) {
  html.div(
    [
      attribute.class(
        "relative flex flex-col place-content-center text-center w-[6.25rem] h-[9rem] rounded-xl bg-white shadow-md border-1 "
        <> option.unwrap(additional_classes, ""),
      ),
      attribute.classes([#("border-3", selected)]),
    ],
    [render_value(card), ..render_suit(card)],
  )
}

fn render_suit(card: Card) -> List(Element(Msg)) {
  [
    html.div([attribute.class("absolute text-3xl left-2 top-2")], [
      html.text(card |> card.suit_short_string),
    ]),
    html.div([attribute.class("absolute text-3xl right-2 bottom-2")], [
      html.text(card |> card.suit_short_string),
    ]),
  ]
}

fn render_value(card: Card) -> Element(Msg) {
  html.span([attribute.class("text-[4rem]")], [
    html.text(card |> card.short_value_string),
  ])
}
