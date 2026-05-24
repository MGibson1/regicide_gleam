import regicide/card.{type Card, type Suit}

pub opaque type Opponent {
  Opponent(health: Int, attack: Int, suit: Suit, card: Card)
}

pub fn health(o: Opponent) -> Int {
  o.health
}

pub fn attack(o: Opponent) -> Int {
  o.attack
}

pub fn suit(o: Opponent) -> Suit {
  o.suit
}

pub fn card(o: Opponent) -> Card {
  o.card
}

pub fn from(card: Card) -> Opponent {
  Opponent(
    health: health_for(card),
    attack: attack_for(card),
    suit: card |> card.suit,
    card: card,
  )
}

pub fn damage(o: Opponent, by dmg: Int) -> Opponent {
  Opponent(..o, health: o.health - dmg)
}

fn health_for(card: Card) -> Int {
  attack_for(card) * 2
}

fn attack_for(card: Card) -> Int {
  card |> card.attack_value
}
