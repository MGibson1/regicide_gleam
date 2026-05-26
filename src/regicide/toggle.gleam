import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

// Tailwind plus toggle element
// https://tailwindcss.com/plus/ui-blocks/application-ui/forms/toggles#component-b3e0a15571300f79fced5845f97fa972

type Option(msg) =
  #(String, msg)

pub type Position {
  Left
  Right
}

pub fn toggle(
  name: String,
  left: Option(msg),
  right: Option(msg),
  init: Position,
) -> Element(msg) {
  let init = case init {
    Left -> False
    Right -> True
  }

  html.div([attribute.class("flex flex-row content-center gap-1")], [
    html.span([], [html.text(left |> label)]),
    html.div(
      [
        attribute.class(
          "group relative inline-flex h-5 w-10 shrink-0 items-center self-center justify-center rounded-full outline-offset-2 outline-indigo-600 has-focus-visible:outline-2",
        ),
      ],
      [
        html.span(
          [
            attribute.class(
              "absolute mx-auto h-4 w-9 rounded-full bg-gray-200 inset-ring inset-ring-gray-900/5 transition-colors duration-200 ease-in-out",
            ),
          ],
          [],
        ),
        html.span(
          [
            attribute.class(
              "absolute left-0 size-5 rounded-full border border-gray-300 bg-white shadow-xs transition-transform duration-200 ease-in-out group-has-checked:translate-x-5",
            ),
          ],
          [],
        ),
        html.input([
          attribute.type_("checkbox"),
          attribute.name(name),
          attribute.aria_label("Use setting"),
          attribute.class(
            "absolute inset-0 size-full appearance-none focus:outline-hidden",
          ),
          attribute.checked(init),
          event.on_check(parse_change(_, left, right)),
        ]),
      ],
    ),
    html.span([], [html.text(right |> label)]),
  ])
}

fn parse_change(b: Bool, left: Option(msg), right: Option(msg)) -> msg {
  case b |> echo {
    True -> right |> message
    False -> left |> message
  }
}

fn label(o: Option(msg)) -> String {
  let #(str, _) = o
  str
}

fn message(o: Option(msg)) -> msg {
  let #(_, message) = o
  message
}
