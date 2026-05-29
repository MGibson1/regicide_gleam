import gleam/option
import gleeunit/should
import history

pub fn new_history_test() {
  history.new(1.0) |> should.equal(history.new(1.0))
}

pub fn with_test() {
  history.with([1.0, 2.0]) |> history.current |> should.equal(2.0)
  history.with([1.0, 2.0]) |> history.current_index |> should.equal(1)
  history.with([1.0, 2.0]) |> history.prev |> should.equal(option.Some(1.0))
  history.with([1.0, 2.0]) |> history.next |> should.be_none
}

pub fn current_yields_current_value_test() {
  history.new(1.0) |> history.current |> should.equal(1.0)
}

pub fn current_index_yields_current_index_test() {
  history.new(1.0) |> history.current_index |> should.equal(0)
}

pub fn update_test() {
  history.new(1.0) |> history.update(2.0) |> should.equal(history.new(2.0))
  history.with([1.0, 2.0])
  |> history.update(3.0)
  |> should.equal(history.with([1.0, 3.0]))
}

pub fn append_moves_cursor_test() {
  history.new(1.0)
  |> history.append(2.0)
  |> history.current_index
  |> should.equal(1)
}

pub fn append_updates_current_value_test() {
  history.new(1.0)
  |> history.append(2.0)
  |> history.current
  |> should.equal(2.0)
}

pub fn append_drop_undone_values_test() {
  history.with([1.0, 2.0, 3.0, 4.0])
  |> history.undo
  |> history.undo
  |> history.append(5.0)
  |> should.equal(history.with([1.0, 2.0, 5.0]))
}

pub fn has_prev_test() {
  history.new(1.0) |> history.has_prev |> should.be_false

  history.with([1.0, 2.0])
  |> history.has_prev
  |> should.be_true
}

pub fn prev_test() {
  history.new(1.0) |> history.prev |> should.be_none

  history.with([1.0, 2.0])
  |> history.prev
  |> should.equal(option.Some(1.0))
}

pub fn has_next_test() {
  history.new(1.0) |> history.has_next |> should.be_false
  history.with([1.0, 2.0]) |> history.has_next |> should.be_false

  history.with([1.0, 2.0])
  |> history.undo
  |> history.has_next
  |> should.be_true
}

pub fn next_test() {
  history.new(1.0) |> history.next |> should.be_none
  history.with([1.0, 2.0]) |> history.next |> should.be_none

  history.with([1.0, 2.0])
  |> history.undo
  |> history.next
  |> should.equal(option.Some(2.0))
}

pub fn undo_test() {
  history.new(1.0) |> history.undo |> should.equal(history.new(1.0))
  history.with([1.0, 2.0])
  |> history.undo
  |> history.undo
  |> history.undo
  |> history.undo
  |> history.undo
  |> should.equal(history.with([1.0, 2.0]) |> history.undo |> history.undo)

  let undone = history.with([1.0, 2.0]) |> history.undo
  undone |> history.next |> should.equal(option.Some(2.0))
  undone |> history.current |> should.equal(1.0)
  undone |> history.current_index |> should.equal(0)
}

pub fn redo_test() {
  history.with([1.0, 2.0])
  |> history.undo
  |> history.redo
  |> history.redo
  |> history.redo
  |> history.redo
  |> should.equal(history.with([1.0, 2.0]))
}
