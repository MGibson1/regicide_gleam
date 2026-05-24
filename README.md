# regicide

[![Package Version](https://img.shields.io/hexpm/v/regicide)](https://hex.pm/packages/regicide)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/regicide/)

```sh
gleam add regicide@1
```

```gleam
import regicide

pub fn main() -> Nil {
  // TODO: An example of the project in use
}
```

Further documentation can be found at <https://hexdocs.pm/regicide>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```

## rules

Standard deck of cards

- initialize by dealing into five piles
  - castle (all face cards, sort by face value shuffled suits)
  - tavern (rest, shuffled)
  - deal 8 into hand from tavern
  - del 1 into opponent from castle
  - two jokers to side
  - empty discard pile

Each suit has a different "power"

- club: (club) double damage
- spade: (shield) block damage
- heart: (heart) shuffle discard, draw into tavern
- diamond: (quill) draw from tavern into hand (max 8)
- joker: discard hand and draw from tavern to 8

Face values have two states

- as opposition
  - King:
    - damage: 20
    - health: 40
  - Queen:
    - damage: 15
    - health: 30
  - Jack:
    - damage: 10
    - health: 20
- in hand
  - king: 20
  - queen: 15
  - jack: 10

### Turns of play

Player starts and may select cards to attack with from their hand

- duplicates may be played together up to a total power of 10
- aces of any suit can be played with up to one of any other card
- when playing a set of cards, all powers played apply. Resolve hearts before draw
- shield's are cumulative over an entire encounter
