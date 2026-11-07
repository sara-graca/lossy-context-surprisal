"""Load the Natural Stories texts.
"""
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parent.parent      # repo folder (this file is in src/)
RT_FILE = ROOT / "data" / "naturalstories" / "naturalstories_RTS" / "processed_RTs.tsv"


def load_stories():
    """Return {story number: [word1, word2, ...]} for the 10 stories."""
    # the reading-time file has one row per participant x word; we only need the words
    df = pd.read_csv(RT_FILE, sep="\t", usecols=["item", "zone", "word"])
    df = df.drop_duplicates().sort_values(["item", "zone"])   # each word once, in order
    # in this file 'item' is the story number (1 to 10)
    return {story: group["word"].tolist() for story, group in df.groupby("item")}