import gleam/dynamic/decode
import gleam/json

pub type UiState {
  UiState
}

pub fn ui_state_to_json(_ui_state: UiState) -> json.Json {
  json.string("ui_state")
}

pub fn ui_state_decoder() -> decode.Decoder(UiState) {
  use variant <- decode.then(decode.string)
  case variant {
    "ui_state" -> decode.success(UiState)
    _ -> decode.failure(UiState, "UiState")
  }
}

pub fn new() -> UiState {
  UiState
}
