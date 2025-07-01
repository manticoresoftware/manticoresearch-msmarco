import os

input_file = "../datasets/msmarco-docs.tsv"
output_dir = "../datasets/shards"
num_shards = 32

# Create output directory if it doesn't exist
os.makedirs(output_dir, exist_ok=True)

# Initialize file handles for each shard
shard_files = [
    open(f"{output_dir}/msmarco-docs-shard-{i}.tsv", "w")
    for i in range(num_shards)
]

# Read input file and distribute lines
with open(input_file, "r") as f:
    for line in f:
        # Assuming docid is the first column and numeric
        docid = line.split("\t")[0]
        try:
            shard_index = int(docid) % num_shards
            shard_files[shard_index].write(line)
        except ValueError:
            print(f"Skipping invalid docid: {docid}")

# Close all shard files
for f in shard_files:
    f.close()