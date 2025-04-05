#!/usr/bin/env python3
import json
from contextlib import contextmanager
from itertools import count
from pathlib import Path

conversations = {}
current_conversation = None
current_conversation_name = None
current_label = None
current_markers = None
choice_id_gen = None


def dump_scripts():
    cwd = Path.cwd()
    if cwd.name == "scripts":
        scripts_dir = cwd
    elif (cwd / "scripts").is_directory():
        scripts_dir = cwd / "scripts"

    for name, conversation in conversations.items():
        with open(scripts_dir / f"script-{name}.json", "w") as f:
            json.dump(conversation, f)
            f.write("\n")


@contextmanager
def conversation(name):
    if name in conversations:
        raise RuntimeError(f"Duplicate conversation name {name!r}")

    global current_conversation
    current_conversation = []

    global current_conversation_name
    current_conversation_name = name

    global current_markers
    current_markers = set()

    global choice_id_gen
    choice_id_gen = count(start=1)

    conversations[name] = current_conversation
    marker("start")

    yield

    current_conversation = None
    current_conversation_name = None


def marker(label: int | str):
    label = str(label)
    if label in current_markers:
        raise RuntimeError(
            f"Duplicate marker label {label!r} in conversation {current_conversation_name!r}"
        )

    current_markers.add(label)
    current_conversation.append({"marker": label})


def them(*lines):
    current_conversation.append({"them": [*lines]})


def you(choices_or_line: dict[str, int] | str):
    if isinstance(choices_or_line, dict):
        prepared_choices = [
            {
                "id": next(choice_id_gen),
                "line": line,
                "next": str(next_marker_label),
            }
            for line, next_marker_label in choices_or_line.items()
        ]
    else:
        prepared_choices = [
            {
                "id": next(choice_id_gen),
                "line": choices_or_line,
                "next": None,
            }
        ]
    current_conversation.append({"you": prepared_choices})


###
### CONVERSATIONS
###

with conversation("test"):
    them("Hello! It's nice to finally meet you!")
    you(
        {
            "And also with you!": 1,
            "Technically, we haven't met yet.": 2,
        }
    )

    marker(1)
    them("*bows profusely*")
    you({"Yep": 3})

    marker(2)
    them(
        "...",
        ".....",
        "................",
    )
    you("Yep")

    marker(3)
    them("So... how do you feel about the economy?")
    you("Yes")


dump_scripts()
