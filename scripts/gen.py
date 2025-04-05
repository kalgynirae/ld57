#!/usr/bin/env python3
from contextlib import contextmanager
from dataclasses import dataclass
from itertools import count

conversations = {}
current_conversation = None
current_conversation_name = None
current_label = None
current_section = None
choice_id_gen = None


def dump_conversations():
    for name, conversation in conversations.items():

@contextmanager
def conversation(name):
    if name in conversations:
        raise RuntimeError(f"Duplicate conversation name {name!r}")

    global current_conversation
    current_conversation = {}

    global current_conversation_name
    current_conversation_name = name

    global choice_id_gen
    choide_id_gen = count(start=1)

    conversations[name] = current_conversation
    section("start")
    try:
        yield
    finally:
        current_conversation = None
        current_conversation_name = None


def section(label: int | str):
    label = str(label)
    if label in current_conversation:
        raise RuntimeError(
            f"Duplicate section label {label!r} in conversation {current_conversation_name!r}"
        )

    global current_label
    current_label = label

    global current_section
    current_section = []

    current_conversation[label] = current_section


def them(*lines):
    current_section.append({"them": [*lines]})


def you(choices: dict[str, int] | list[str]):
    if isinstance(choices, dict):
        prepared_choices = [
            (next(choice_id_gen), line, str(next_section_label)),
            for line, next_section_label in choices.items()
        ]
    current_section.append({"you": [(next(choice_id_gen), line, next_section)]})


with conversation("test"):
    them("Hello! It's nice to finally meet you!")
    you(
        {
            "And also with you!": 1,
            "Technically, we haven't met yet.": 2,
        }
    )

    section(1)
    them("*bows profusely*")
    you({"Yep": 3})

    section(2)
    them(
        "...",
        ".....",
        "................",
    )
    you({"Yep": 3})

    section(3)
    them("So... how do you feel about the economy?")

dump_conversations()
