#import "@preview/bullseye:0.1.0": on-target, target

#let __elem(tag, attrs: (:), body) = context if target() == "html" {
  html.elem(tag, attrs: attrs, body)
}

#let on_typki = "typki" in sys.inputs

#let frame(body, text_color: rgb("#0099FF")) = context {
  if target() == "html" {
    set text(fill: text_color)
    html.frame(body)
  } else {
    body
  }
}

/// lets all math equations be in a frame on html
#let math-framed(body) = {
  show math.equation: it => {
    if it.block {
      frame(it)
    } else {
      box(frame(it))
    }
  }
  body
}

// state layout:
// ("deck": (("", false), ("deck1", force), ("deck2", true)), "note-type": (none, "basic", "basic and reverse"))
#let __state_name = "typki-data"

#let __checked_init_state() = {
  let data = state(__state_name).get()
  if data == none {
    data = ("deck": (("", false),), "note-type": (none,), "existing-guids": ("",))
    let _ = state(__state_name).update(data)
  }
  data
}

#let __active_deck() = {
  let data = __checked_init_state()
  let final_deck = data.at("deck").last()
  for deck in data.at("deck") {
    if deck.at(1) {
      final_deck = deck
      break
    }
  }
  final_deck
}

#let display_field1(field1, _, typki_body) = {
  field1
  typki_body
}
#let display_field2(_, field2, typki_body) = {
  field2
  typki_body
}
#let display_all(field1, field2, typki_body) = {
  field1
  field2
  typki_body
}
#let display_array(field1, field2, typki_body) = (
  field1,
  {
    field2
    typki_body
  },
)
#let display_none(_, _, typki_body) = typki_body

/// Adds a note to the Anki export for the given name.
#let note(guid, field1, field2, note-type: none, deck: none, display: display_none) = {
  if guid == "" {
    panic("guid can not be an empty string")
  }
  if on_typki {
    display([], [], context {
      let data = __checked_init_state()

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
    })
  } else {
    display(field1, field2, context {
      let data = __checked_init_state()
      if guid in data.at("existing-guids") {
        panic("Guid " + guid + "already exists!")
      } else {
        data.at("existing-guids").push(guid)
        state(__state_name).update(data)
      }
    })
  }
}

#let basic-reverse(guid, field1, field2, deck: none, display: display_none) = note(
  guid,
  field1,
  field2,
  deck: deck,
  note-type: "Basic (and reversed card)",
  display: display,
)

#let basic(guid, field1, field2, deck: none, display: display_none) = note(
  guid,
  field1,
  field2,
  deck: deck,
  note-type: "Basic",
  display: display,
)

#let cloze(guid, field1, field2: "", deck: none, display: display_none) = note(
  guid,
  field1,
  field2,
  deck: deck,
  note-type: "Cloze",
  display: display,
)

#let c(number, body, hint: none) = {
  if on_typki {
    // FIXME: this does not escape! Should use elem instead so that the python script can do the escaping
    "{{c" + str(number) + "::"
    body
    if hint != none {
      "::"
      hint
    }
    "}}"
  } else {
    body
  }
}

#let with-note-type(note-type, body) = {
  if on_typki() {
    context {
      let data = __checked_init_state()
      data.at("note-type").push(note-type)
      state(__state_name).update(data)
    }
  }
  body
}

#let with-deck(deck, force: false, sub-deck: false, body) = {
  if on_typki {
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
        data.at("deck").push((deck, force))
        state(__state_name).update(data)
      }
    }
  }
  body
}
