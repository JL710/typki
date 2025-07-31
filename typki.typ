#import "@preview/bullseye:0.1.0": on-target, target

#let __elem(tag, attrs: (:), body) = context if target() == "html" {
  html.elem(tag, attrs: attrs, body)
}

#let __on_anki = "typki" in sys.inputs

#let frame(body, text_color: rgb("#0099FF")) = context {
  if target() == "html" {
    set text(fill: text_color)
    html.frame(body)
  } else {
    body
  }
}

// state layout:
// ("decks": (("", false), ("deck1", force), ("deck2", true)), "note-type": (none, "basic", "basic and reverse"))
#let __state_name = "anki-data"

#let __checked_init_state() = {
  let data = state(__state_name).get()
  if state(__state_name).get() == none {
    data = ("decks": (("", false),), "note-type": (none,))
    let _ = state(__state_name).update(data)
  }
  data
}

#let __active_deck() = {
  let data = __checked_init_state()
  let final_deck = data.at("decks").last()
  for deck in data.at("decks") {
    if deck.at(1) {
      final_deck = deck
      break
    }
  }
  final_deck
}

#let display_field1(field1, _) = field1
#let display_field2(_, field2) = field2
#let display_all(field1, field2) = {
  field1
  field2
}

/// Adds a note to the Anki export for the given name.
#let note(guid, field1, field2, note-type: none, deck: none, display: (a, b) => {}) = {
  if guid == "" {
    panic("guid can not be an empty string")
  }
  context {
    let data = __checked_init_state()

    if __on_anki {
      let note-deck = deck
      if note-deck == none {
        note-deck = __active_deck().at(0)
      }

      let note-type = note-type
      if note-type == none {
        if data.at("note-type").last() == none {
          note-type = ""
        } else {
          note-type = data.at("note-type").last()
        }
      }

      __elem("anki", {
        __elem("meta", attrs: (guid: guid, note-type: note-type, deck: note-deck), [])
        __elem("field1", field1)
        __elem("field2", field2)
      })
    }

    on-target(paged: {
      display(field1, field2)
    })
  }
}

#let basic-reverse(guid, field1, field2, deck: none, display: (a, b) => {}) = note(
  guid,
  field1,
  field2,
  deck: deck,
  note-type: "Basic (and reversed card)",
  display: display,
)

#let basic(guid, field1, field2, deck: none, display: (a, b) => {}) = note(
  guid,
  field1,
  field2,
  deck: deck,
  note-type: "Basic",
  display: display,
)

#let cloze(guid, field1, field2, deck: none, display: (a, b) => {}) = note(
  guid,
  field1,
  field2,
  deck: deck,
  note-type: "Cloze",
  display: display,
)

#let with-note-type(note-type, body) = {
  if __on_anki {
    context {
      let data = __checked_init_state()
      data.at("note-type").push(note-type)
      state(__state_name).update(data)
    }
  }
  body
}

#let with-deck(deck, force: false, sub-deck: false, body) = {
  if __on_anki {
    context {
      let active_deck = __active_deck()
      if not active_deck.at(1) {
        let data = __checked_init_state()
        let deck = deck
        if sub-deck {
          if active_deck != "" {
            deck = active_deck.at(0) + "::" + deck
          }
        }
        data.at("decks").push((deck, force))
        state(__state_name).update(data)
      }
    }
  }
  body
}
