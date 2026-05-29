import gleam/dynamic/decode
import gleam/json
import gleam/result
import history
import lustre/effect.{type Effect}
import plinth/javascript/storage
import regicide/card.{type Card}
import regicide/game_state.{type GameState}
import regicide/ui_state.{type Sort, type UiState}

pub type ModelWithHistory =
  history.History(Model)

pub type Model {
  None
  GameInProgress(history.History(Playing))
}

pub type Playing {
  Playing(gs: GameState, ui: UiState)
}

pub fn next(model: Model, next: Playing) {
  case model {
    None -> model
    GameInProgress(history) -> GameInProgress(history |> history.append(next))
  }
}

pub fn update(model: Model, with: Playing) {
  case model {
    None -> model
    GameInProgress(history) -> GameInProgress(history |> history.update(with))
  }
}

pub fn undo(model: Model) {
  case model {
    None -> model
    GameInProgress(history) -> GameInProgress(history |> history.undo)
  }
}

pub fn redo(model: Model) {
  case model {
    None -> model
    GameInProgress(history) -> GameInProgress(history |> history.redo)
  }
}

fn playing_to_json(playing: Playing) -> json.Json {
  let Playing(gs:, ui:) = playing
  json.object([
    #("gs", game_state.game_state_to_json(gs)),
    #("ui", ui_state.ui_state_to_json(ui)),
  ])
}

fn playing_decoder() -> decode.Decoder(Playing) {
  use gs <- decode.field("gs", game_state.game_state_decoder())
  use ui <- decode.field("ui", ui_state.ui_state_decoder())
  decode.success(Playing(gs:, ui:))
}

fn model_to_json(model: Model) -> json.Json {
  case model {
    None ->
      json.object([
        #("type", json.string("none")),
      ])
    GameInProgress(history) -> {
      json.object([
        #("type", json.string("gameInProgress")),
        #("data", history.history_to_json(history, playing_to_json)),
      ])
    }
  }
}

pub fn model_decoder() -> decode.Decoder(Model) {
  use variant <- decode.field("type", decode.string)
  case variant {
    "none" -> decode.success(None)
    "gameInProgress" -> {
      use history <- decode.field(
        "data",
        history.history_decoder(playing_decoder()),
      )
      decode.success(GameInProgress(history))
    }
    _ -> decode.failure(None, "Model")
  }
}

pub type Msg {
  UserClickedStartGame
  UserClickedForfeit
  UserClickedRedraw
  UserClickedCardInHand(Card)
  UserClickedPlayCards
  UserChangedSort(Sort)
  UserClickedUndo
  UserClickedRedo

  GameSaved
  GameLoaded(Model)

  /// empty message because lustre doesn't expose the effect.empty constant
  Empty
}

pub fn save(model: Model, message: msg) -> Effect(msg) {
  use dispatch <- effect.from

  let _ =
    storage.local()
    |> result.map(storage.set_item(
      _,
      "saved_game",
      model |> model_to_json |> json.to_string,
    ))
    |> result.flatten

  message |> echo |> dispatch

  Nil
}

pub fn load_save() -> Effect(Msg) {
  use dispatch <- effect.from

  let load =
    storage.local()
    |> result.map(storage.get_item(_, "saved_game"))
    |> result.flatten
    |> result.map(json.parse(_, using: model_decoder()))
    |> result.map(result.map_error(_, fn(_) { Nil }))
    |> result.flatten

  case load {
    Ok(model) -> dispatch(GameLoaded(model))
    Error(_) -> dispatch(Empty)
  }

  Nil
}

pub fn delete_save() -> Effect(Msg) {
  use dispatch <- effect.from

  let _delete =
    storage.local()
    |> result.map(storage.remove_item(_, "saved_game"))

  echo "save deleted"

  dispatch(Empty)

  Nil
}
