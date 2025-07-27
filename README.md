# typki
## Use in typst

Copy [`typki.typ`](./typki.typ) into your project.

Create simple notes:
```typ
#import "typki.typ": note, basic

#note(
  "50c5c9ad-dd5f-40c9-8e4c-bae25271caf0",
  [Question],
  [Answer],
  note-type: "Basic",
)

// Shorthand
#basic(
  "50c5c9ad-dd5f-40c9-8e4c-bae25271caf0",
  [Question],
  [Answer],,
)
```
There are shorthands for:
- `basic`
- `basic-reverse`
- `cloze`
> **Note:** These only work when your note types are the default english ones! If you have set your language to a different one, you might need to create your own shorthands.

> **Note:** When changing the deck in typst, this can not be transferred to anki.

### Note Parameters

- `guid`: The global ID of your note (used to identify it). These **must** be unique through out your whole anki collection!
- `field1`: Any content (commonly the question)
- `field2`: Any content (commonly the answer)
- `deck: none`: Specifies the deck. If left to `none`, the parent deck is used.
- `note-type: none`: Specifies the note-type. If left to `none`, the parent deck is used.
- `display: (a, b) => {}`: A function used to optionally display the note in the pdf. It takes both fields as arguments and returns a content that is displayed where the note is created.

### Create custom shorthands

```typ
#let cloze(guid, field1, field2, deck: none, display: (a, b) => {}) = note(
  guid,
  field1,
  field2,
  deck: deck,
  note-type: "Cloze",
  display: display,
)
```

### Default Decks

```typ
#import "typki.typ": with-deck
```

Set the default deck for the rest of the document:
```typ
#show: with-deck.with("test-deck")
```

Set the default deck for a part of the document:
```typ
#with-deck("parent")[
  // this note will be in deck "parent"
  #basic("1", [A], [B])

  #with-deck("child-deck")[
    // this note will be in deck "child-deck"
    #basic("2", [A], [B])
  ]

  // this note will be in deck "parent"
  #basic("3", [A], [B])
]
```

Parameters of with-deck:
- `deck`: The name of the deck
- `force: false`: If set to true, prevents setting new parent decks inside of this one 
- `sub-deck: false`: If set to true, makes the deck a subdeck of the previous parent deck
- `body`: The area where the deck is applied to 

### Html Trouble

Since the typst content is compiled to html, your whole document needs to be html compatible.

#### Elements that are only available on paged

This means that you can not use stuff like `set page` that is not valid on html as before.
Instead you can use `on_paged` from typki.

If you had previously:
```typ
#set page(header: [example header])

#lorem(15)
```
You need to convert it to:
```typ
#import "typki.typ": on_paged

#show: on_paged.with(body => {
  set page(header: [example header])
  body
})

#lorem(15)
```
Sadly, there is no better workaround for this yet.

#### Elements that can not be properly converted on html
Elements like math can not be properly converted to html. 
Fortunately there is a workaround for that.

Wrapping an element in `frame` converts it to svg and embeds that into the html. That way elements can be displayed properly on html.

```typ
#import "typki.typ": frame

#frame[$ x / y^2 $]
```

> **Note:** Text inside of the svg can not adapt to the font color set in html. This is why typki sets a font that can be read quite good on dark and light backgrounds.

## Install and use Cli

Having installed the [typst cli]() is a requirement for typki.
```
pip install git+https://github.com/JL710/typki.git
```

Generating the anki txt.
```
typki your_typst_document.typ [typst compile arguments]
```
This will create a `anki-export.txt` that can be imported by anki.
