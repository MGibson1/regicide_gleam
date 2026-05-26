import gleam/dynamic/decode
import gleam/json

pub type UiState {
  UiState(sort: Sort)
}

pub fn sort(_ui: UiState, by sort: Sort) -> UiState {
  UiState(sort:)
}

pub fn ui_state_to_json(ui_state: UiState) -> json.Json {
  let UiState(sort:) = ui_state
  json.object([
    #("sort", sort_to_json(sort)),
  ])
}

pub fn ui_state_decoder() -> decode.Decoder(UiState) {
  use sort <- decode.field("sort", sort_decoder())
  decode.success(UiState(sort:))
}

pub type Sort {
  BySuit
  ByValue
}

pub fn sort_to_json(sort: Sort) -> json.Json {
  case sort {
    BySuit -> json.string("by_suit")
    ByValue -> json.string("by_value")
  }
}

pub fn sort_decoder() -> decode.Decoder(Sort) {
  use variant <- decode.then(decode.string)
  case variant {
    "by_suit" -> decode.success(BySuit)
    "by_value" -> decode.success(ByValue)
    _ -> decode.failure(BySuit, "Sort")
  }
}

pub fn new() -> UiState {
  UiState(sort: BySuit)
}
