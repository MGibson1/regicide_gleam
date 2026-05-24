import regicide/card.{type Card}
import regicide/game_state.{type GameState}
import regicide/ui_state.{type UiState}

pub type Model {
  None
  Playing(gs: GameState, ui: UiState)
}

pub type Msg {
  UserClickedStartGame
  UserClickedForfeit
  UserClickedRedraw
  UserClickedCardInHand(Card)
  UserClickedPlayCards
}
