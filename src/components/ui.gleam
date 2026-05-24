import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import model.{type Msg}

pub fn labeled_text(label: String, text: String) -> Element(Msg) {
  html.div([attribute.class("flex justify-center content-center")], [
    html.label([attribute.class("mr-2")], [html.text(label <> ":")]),
    html.text(text),
  ])
}
