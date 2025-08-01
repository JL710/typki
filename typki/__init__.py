import sys
import subprocess
import os
from dataclasses import dataclass
from bs4 import BeautifulSoup

def escape_str(field: str) -> str:
    return "\"" + field.replace("\"", "\"\"").strip(" ").strip("\n").strip(" ").strip("\n") + "\""

def remove_spacing(content: str) -> str:
    lines = content.splitlines(True)
    smallest_spacing = None
    for line in lines:
        spaces = len(line) - len(line.lstrip(" "))
        if smallest_spacing is None or spaces < smallest_spacing:
            smallest_spacing = spaces

    if smallest_spacing is not None:
        for i in range(len(lines)):
            lines[i] = lines[i][spaces:]
    return "".join(lines)

def compile_typst(location, args) -> str:
    output_path = "anki-export.html"
    try:
        subprocess.check_output(f"typst compile --input typki=\"\" --features html --format html {location} {output_path} {' '.join(args)}", shell=True)
    except subprocess.CalledProcessError:
        print("Error while compiling the document", file=sys.stderr)
        sys.exit(1)
    with open(output_path, "r", encoding="utf-8") as f:
        html = "".join(f.readlines())
    os.remove(output_path)
    return html

@dataclass
class Note:
    guid: str
    deck: str
    note_type: str
    field1: str
    field2: str

def html_children_to_string(perent_element) -> str:
    return remove_spacing("".join([BeautifulSoup(str(x.encode(), "utf-8"), "html.parser").prettify(formatter="minimal") for x in perent_element.contents]))

def parse_notes(content) -> list[Note]:
    soup = BeautifulSoup(content, "html.parser")

    notes = []

    for anki_tag in soup.find_all("anki"):
        meta_tag = anki_tag.find("meta")
        notes.append(Note(
            meta_tag["guid"], 
            meta_tag["deck"], 
            meta_tag["note-type"], 
            html_children_to_string(anki_tag.find("field1")),
            html_children_to_string(anki_tag.find("field2")),
            )
        )

    return notes

def generate_anki_file(notes: list[Note]) -> str:
    content = "#notetype column:1\n"
    content += "#guid column:2\n"
    content += "#deck column: 3\n"
    content += "#html:true\n"
    content += "#separator:Semicolon\n"

    for note in notes:
        content += f"{note.note_type};{note.guid};{note.deck};{escape_str(note.field1)};{escape_str(note.field2)}\n"
    
    return content

def main():
    file = sys.argv[1]

    total_content = compile_typst(file, sys.argv[2:])

    notes = parse_notes(total_content)

    with open("anki-export.txt", "w", encoding="utf-8") as f:
        f.write(generate_anki_file(notes))

if __name__ == "__main__":
    main()
