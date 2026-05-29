import components/play_mat
import history
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import model.{
  type Model, type Msg, Empty, GameInProgress, GameLoaded, GameSaved, None,
  Playing, UserChangedSort, UserClickedCardInHand, UserClickedForfeit,
  UserClickedPlayCards, UserClickedRedo, UserClickedRedraw, UserClickedStartGame,
  UserClickedUndo,
}
import regicide/game_state.{type GameState}
import regicide/ui_state.{type UiState}

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

fn init(_args) -> #(Model, Effect(Msg)) {
  #(None, model.load_save())
}

fn update(model: Model, message: Msg) -> #(Model, Effect(Msg)) {
  case message {
    UserClickedStartGame -> {
      #(
        GameInProgress(
          history.new(Playing(gs: game_state.new(), ui: ui_state.new())),
        ),
        model.save(model, GameSaved),
      )
    }
    UserClickedForfeit -> #(None, model.delete_save())
    UserClickedRedraw ->
      case model {
        None -> #(model, effect.none())
        GameInProgress(h) -> {
          let Playing(gs, ui) = h |> history.current
          let model = model |> model.next(Playing(gs |> game_state.redraw, ui))
          #(model, model.save(model, GameSaved))
        }
      }
    UserClickedCardInHand(card) ->
      case model {
        None -> #(model, effect.none())
        GameInProgress(h) -> {
          let Playing(gs, ui) = h |> history.current
          let model =
            model
            |> model.update(Playing(gs |> game_state.toggle_selected(card), ui))
          #(model, model.save(model, GameSaved))
        }
      }
    UserClickedPlayCards ->
      case model {
        None -> #(model, effect.none())
        GameInProgress(h) -> {
          let Playing(gs, ui) = h |> history.current
          let model =
            model
            |> model.next(Playing(gs |> game_state.take_turn, ui))
          #(model, model.save(model, GameSaved))
        }
      }
    UserChangedSort(by) ->
      case model {
        None -> #(model, effect.none())
        GameInProgress(h) -> {
          let Playing(gs, ui) = h |> history.current
          let model =
            model
            |> model.update(Playing(gs, ui |> ui_state.sort(by)))
          #(model, model.save(model, GameSaved))
        }
      }
    UserClickedUndo ->
      case model {
        None -> #(model, effect.none())
        GameInProgress(h) -> {
          let model = model |> model.undo
          #(model, model.save(model, GameSaved))
        }
      }
    UserClickedRedo ->
      case model {
        None -> #(model, effect.none())
        GameInProgress(h) -> {
          let model = model |> model.redo
          #(model, model.save(model, GameSaved))
        }
      }

    GameSaved -> #(model, effect.none())
    GameLoaded(loaded) -> #(loaded, effect.none())

    Empty -> #(model, effect.none())
  }
}

fn view(model: Model) -> Element(Msg) {
  html.div([attribute.id("container")], [
    {
      case model {
        None -> full_screen_button("Start Game", UserClickedStartGame)
        GameInProgress(history) -> {
          let Playing(gs, ui) = history |> history.current
          game_view(gs, ui)
        }
      }
    },
  ])
}

fn full_screen_button(text: String, on_click: Msg) -> Element(Msg) {
  html.div(
    [
      attribute.class("flex h-screen w-screen justify-center center-content"),
    ],
    [
      html.button(
        [
          attribute.class("w-full h-full"),
          event.on_click(on_click),
        ],
        [
          html.text(text),
        ],
      ),
    ],
  )
}

fn game_view(gs: GameState, ui: UiState) -> Element(Msg) {
  case gs.phase {
    game_state.Lost -> {
      full_screen_button("Lost", UserClickedForfeit)
    }
    game_state.Won -> {
      full_screen_button("Won!!", UserClickedForfeit)
    }
    _ -> {
      html.div([attribute.class("flex flex-col")], [
        html.h1([], [html.text("playing")]),
        play_mat.play_ui(gs, ui),
        html.div(
          [attribute.class("flex flex-row flex-wrap gap-3 justify-center")],
          [
            html.button([event.on_click(UserClickedForfeit)], [
              html.text("Forfeit"),
            ]),
          ],
        ),
      ])
    }
  }
}
