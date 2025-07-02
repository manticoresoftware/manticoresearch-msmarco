import mysql.connector
import pandas as pd
from tqdm import tqdm
import argparse
import os
from dotenv import load_dotenv

def escape_query(text):
    """Escape characters for Manticore MATCH() syntax."""
    if text is None:
        return ""
    text = text.replace('\\', '\\\\')
    text = text.replace("'", "\\'").replace('"', '\\"').replace('(', '\\(').replace(')', '\\)').replace('/', '\\/')
    return text

# Load environment variables
load_dotenv()

# Parse command-line arguments
parser = argparse.ArgumentParser(description="Rank documents using Manticore search")
parser.add_argument('--output', default='manticore_default_run.tsv', help='Output file name for ranking results')
args = parser.parse_args()

# Connect to Manticore
conn = mysql.connector.connect(
    host=os.getenv("MANTICORE_HOST", "127.0.0.1"),
    port=int(os.getenv("MANTICORE_PORT", "9306")),
    user="",
    password=""
)
cur = conn.cursor()

# Load dev query IDs
dev_queries = pd.read_csv("datasets/msmarco-docdev-queries.tsv", sep="\t", names=["qid", "query_text"])
results = []

# Rank documents for each dev query
for _, row in tqdm(dev_queries.iterrows(), total=len(dev_queries), desc="Ranking"):
    qid = row["qid"]
    cur.execute(
        "SELECT query_text FROM msmarco_queries WHERE qid = %s",
        (qid,)
    )
    query_text = cur.fetchone()
    if query_text is None:
        print(f"Warning: No query text found for qid {qid}, skipping")
        continue
    query_text = escape_query(query_text[0])
    try:
        # Use raw string to prevent Python double-escaping
        cur.execute(
            r"""
            SELECT docid, WEIGHT() AS score
            FROM msmarco_docs
            WHERE MATCH(%s)
            ORDER BY score DESC
            LIMIT 10
            """,
            (query_text,)
        )

        for rank, (docid, score) in enumerate(cur.fetchall(), 1):
            results.append((qid, docid, rank))
    except mysql.connector.Error as e:
        print(f"Error for qid {qid}: {e} (Query: {query_text})")
        continue

# Save results
with open(args.output, "w") as f:
    for qid, docid, rank in results:
        f.write(f"{qid}\t{docid}\t{rank}\n")

conn.close()
print(f"Ranking completed: {args.output} generated")