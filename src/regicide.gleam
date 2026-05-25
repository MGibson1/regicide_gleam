import components/discard_ui.{discard_view}
import components/hand_ui.{view_hand}
import components/in_play_ui.{view_in_play}
import components/opponent_ui.{opponent_view}
import components/play_mat
import components/tavern_ui.{tavern_view}
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import model.{
  type Model, type Msg, None, Playing, UserClickedCardInHand, UserClickedForfeit,
  UserClickedPlayCards, UserClickedRedraw, UserClickedStartGame,
}
import regicide/game_state.{type GameState, Attacking, Defending}
import regicide/ui_state.{type UiState}

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

fn init(_args) -> #(Model, Effect(Msg)) {
  let model = None

  #(model, effect.none())
}

fn update(model: Model, message: Msg) -> #(Model, Effect(Msg)) {
  case message {
    UserClickedStartGame -> #(
      Playing(gs: game_state.new(), ui: ui_state.new()),
      effect.none(),
    )
    UserClickedForfeit -> #(None, effect.none())
    UserClickedRedraw ->
      case model {
        None -> #(model, effect.none())
        Playing(gs, ui) -> #(
          Playing(gs |> game_state.redraw, ui),
          effect.none(),
        )
      }
    UserClickedCardInHand(card) ->
      case model {
        None -> #(model, effect.none())
        Playing(gs, ui) -> #(
          Playing(gs |> game_state.toggle_selected(card), ui),
          effect.none(),
        )
      }
    UserClickedPlayCards ->
      case model {
        None -> #(model, effect.none())
        Playing(gs, ui) -> #(
          Playing(gs |> game_state.take_turn, ui),
          effect.none(),
        )
      }
  }
}

fn view(model: Model) -> Element(Msg) {
  html.div([attribute.id("container")], [
    {
      case model {
        None ->
          html.div([], [
            html.button([event.on_click(UserClickedStartGame)], [
              html.text("Start Game"),
            ]),
          ])
        Playing(gs, ui) -> game_view(gs, ui)
      }
    },
  ])
}

fn game_view(gs: GameState, ui: UiState) -> Element(Msg) {
  html.div([attribute.class("flex flex-col")], [
    html.h1([], [html.text("playing")]),
    play_mat.play_ui(gs),
    html.div([attribute.class("flex flex-row flex-wrap gap-3 justify-center")], [
      {
        case gs.phase {
          Attacking(_) ->
            html.button([event.on_click(UserClickedPlayCards)], [
              html.text("Attack"),
            ])
          Defending(_) ->
            html.button(
              [
                attribute.disabled(!{ gs |> game_state.sufficient_losses }),
                event.on_click(UserClickedPlayCards),
              ],
              [html.text("Take Losses")],
            )
          _ -> element.none()
        }
      },
      html.button([event.on_click(UserClickedForfeit)], [
        html.text({
          case gs.phase {
            game_state.Won -> "WON"
            _ -> "Forfeit"
          }
        }),
      ]),
    ]),
  ])
}
