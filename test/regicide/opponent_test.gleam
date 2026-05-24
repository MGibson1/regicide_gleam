import gleeunit/should
import regicide/card
import regicide/opponent

fn opponent(face: card.FaceType) {
  opponent.from(card.card(card.Face(face), card.Club))
}

pub fn health_test() {
  opponent(card.Jack) |> opponent.health |> should.equal(20)
  opponent(card.Queen) |> opponent.health |> should.equal(30)
  opponent(card.King) |> opponent.health |> should.equal(40)
}

pub fn attack_test() {
  opponent(card.Jack) |> opponent.attack |> should.equal(10)
  opponent(card.Queen) |> opponent.attack |> should.equal(15)
  opponent(card.King) |> opponent.attack |> should.equal(20)
}

pub fn suit_test() {
  opponent(card.Jack) |> opponent.suit |> should.equal(card.Club)
}
