import mysql.connector
import pandas as pd
from tqdm import tqdm

def escape_query(text):
    """Escape characters for Manticore MATCH() syntax."""
    if text is None:
        return ""
    text = text.replace('\\', '\\\\')
    text = text.replace("'", "\\'").replace('"', '\\"').replace('(', '\\(').replace(')', '\\)').replace('/', '\\/')
    return text

# Connect to Manticore
conn = mysql.connector.connect(
    host="127.0.0.1",
    port=9306,
    user="",  # Update if needed
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
with open("wordforms_run.tsv", "w") as f:
    for qid, docid, rank in results:
        f.write(f"{qid}\t{docid}\t{rank}\n")

conn.close()
print("Wordforms ranking completed: wordforms_run.tsv generated")