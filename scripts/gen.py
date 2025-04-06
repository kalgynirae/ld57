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
    elif (cwd / "scripts").is_dir():
        scripts_dir = cwd / "scripts"

    for name, conversation in conversations.items():
        data = json.dumps(conversation) + "\n"
        (scripts_dir / f"script-{name}.json").write_text(data)


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


def them(line, *, next=None, emote=None):
    current_conversation.append(
        {
            "them": {
                "line": line,
                "next": None if next is None else str(next),
                "emote": emote,
            }
        }
    )


def you(choices_or_line: dict[str, int] | str):
    if isinstance(choices_or_line, dict):
        prepared_choices = [
            {
                "id": str(next(choice_id_gen)),
                "line": line,
                "next": str(next_marker_label),
            }
            for line, next_marker_label in choices_or_line.items()
        ]
    else:
        prepared_choices = [
            {
                "id": str(next(choice_id_gen)),
                "line": choices_or_line,
                "next": None,
            }
        ]
    current_conversation.append({"you": prepared_choices})


def end():
    current_conversation.append({"end": None})


############################################################
### CONVERSATIONS                                        ###
############################################################

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
    them("...")
    them(".....")
    them("................")
    you("Yep")

    marker(3)
    them("So... how do you feel about the economy?")
    you(
        {
            "Yes": 4,
            "No": 5,
        }
    )

    marker(4)
    them("Uhhhhh... maybe try the other option?", next=3)

    marker(5)
    them("Bye!")


with conversation("millie"):
    them(
        "Hello! I haven't seen you around before. Are you new to the depths?",
        emote="neutral",
    )
    you(
        {
            "Yes. I just dug down here earlier today!": 3,
            "No, we've known each other since elementary school.": 1,
        }
    )

    marker(1)
    them(
        "Really? I think I'd remember seeing your [ACCESSORY] before.",
        emote="surprise",
    )
    you(
        {
            "...You got me. I just dug down here earlier today.": 3,
            "That's because you have a terrible memory.": 2,
        }
    )

    marker(2)
    them(".....", emote="anger")
    them("My memory is just fine, thank you very much.")
    you(
        {
            "Ha ha ha.": "angry",
            "You're right, I just dug down here earlier today.": 3,
        }
    )

    marker("angry")
    them("Hmmmmmmph.")

    marker(3)
    them("Do you like math?", emote="uwu")
    you(
        {
            "Yes": "like math",
            "No": "don't like math",
        }
    )
    marker("like math")
    them("Oh.", emote="surprise")

    marker("don't like math")
    them("I don't like math.", emote="neutral")

    them("Do you like books?", emote="uwu")
    you(
        {
            "Yes": "like books",
            "No": "don't like books",
        }
    )
    marker("like books")
    them("Oh.", emote="surprise")

    marker("don't like books")
    them("I don't like books.", emote="neutral")

    them("Do you like sports?", emote="uwu")
    you(
        {
            "Yes": "like sports",
            "No": "don't like sports",
        }
    )
    marker("like sports")
    them("Oh.", emote="surprise")

    marker("don't like sports")
    them("I don't like sports.", emote="neutral")

    them("So...")
    them("....")
    them("What are you looking for in a partner?")
    you(
        {
            "a good personality": "personality",
            "money": "money",
            "legs": "legs",
            "Well, many things are important to me--honesty, trust, devotion, eyes, "
            "antennae, long walks on the beach, a deep passion for collecting antique "
            "cookware. But if I had to pick one thing, I guess I really value": "long",
        }
    )

    marker("personality")
    them("Oh.", emote="neutral")
    them("Well...")
    them("Okay.")
    them("Anyway...", next="end")

    marker("money")
    them("Oh.", emote="neutral")
    them("I don't have very much of that.", next="end")

    marker("long")
    them("Zzzzzzzzzz...", emote="sleep")
    them("*Millie fell asleep!*")
    you("Wake up!")
    them("Ahhh!", next="end", emote="surprised")

    marker("legs")
    them("I HAVE SO MANY OF THOSE!!!", emote="love")
    end()

    marker("end")
    them("It's been great meeting you!", emote="neutral")

dump_scripts()
