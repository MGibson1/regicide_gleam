import components/discard_ui
import components/hand_ui
import components/in_play_ui
import components/joker_ui
import components/opponent_ui
import components/tavern_ui
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import model.{type Msg}
import regicide/game_state.{type GameState}

pub fn play_ui(gs: GameState) -> Element(Msg) {
  html.div([attribute.class("grid grid-rows-3 gap-3")], [
    html.div([attribute.class("row-1 flex gap-3 justify-self-center")], [
      html.div(
        [
          attribute.class(
            "w-min flex flex-col justify-center col-1 justify-self-end flex-grow",
          ),
        ],
        [
          tavern_ui.tavern_view(gs),
          discard_ui.discard_view(gs),
          joker_ui.joker_view(gs),
        ],
      ),
      html.div([attribute.class("col-2 flex-shrink")], [
        opponent_ui.opponent_card_view(gs),
      ]),
      html.div([attribute.class("col-3 justify-self-start flex-grow")], [
        opponent_ui.opponent_stats_view(gs),
      ]),
    ]),

    in_play_ui.view_in_play(gs),
    hand_ui.view_hand(gs),
  ])
}
// pub fn play_ui(gs: GameState) -> Element(Msg) {
//   html.div([attribute.class("justify-self-center p-2")], [
//     html.div(
//       [attribute.class("flex flex-row justify-center content-center px-12")],
//       [
//         html.div([attribute.class("w-min my-auto")], [
//           tavern_ui.tavern_view(gs),
//           discard_ui.discard_view(gs),
//           joker_ui.joker_view(gs),
//         ]),
//         opponent_ui.opponent_view(gs),
//       ],
//     ),
//     in_play_ui.view_in_play(gs),
//     hand_ui.view_hand(gs),
//   ])
// }
