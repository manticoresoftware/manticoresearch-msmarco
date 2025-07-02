# MSMARCO Document Ranking with Manticore Search
This project implements a document ranking system using Manticore Search on the MSMARCO dataset. It provides scripts to index the dataset, rank documents, and evaluate results against MSMARCO’s evaluation metrics. Manticore Search is a fast, open-source search engine, and MSMARCO is a large-scale dataset for machine learning-based information retrieval.

## Prerequisites

* Python 3.8 or higher
* Docker and Docker Compose
* Git
* Bash (Linux/macOS) or a compatible shell (e.g., Git Bash or PowerShell on Windows)

## Setup and Usage

1. **Download the MSMARCO** dataset archive:
   ```shell
   wget https://repo.manticoresearch.com/repository/misc/msmarco_dataset/datasets.tar.gz
   ```

2. **Extract the Dataset**
   ```shell
   tar -xvzf datasets.tar.gz
   ```

3. **Copy the example environment** file and configure the variables (e.g., MANTICORE_PORT, MANTICORE_HOST, MANTICORE_USER, MANTICORE_PASSWORD):
   ```shell
   cp .env_example .env
   ```

   Edit .env using a text editor to match your setup (e.g., ensure MANTICORE_PORT aligns with docker-compose.yml).

4. **Start Manticore Search**
   ```shell 
   docker compose up -d
   ```

5. **Index the Dataset**
   ```shell
   cd helpers
   bash index.sh  # On Windows: use Git Bash or run equivalent commands in PowerShell
   ```

   Return to the project root:
   ```shell
   cd ..
   ```

6. **Set Up Python Environment**
   ```shell
   python -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

7. **Run the Ranking Script**
   Execute the ranking script, specifying an output file (defaults to manticore_default_run.tsv):

   ```shell
   python baseline_ranking.py --output manticore_default_run.tsv
   ```

8. **Clone the MSMARCO Evaluation** Repository
   ```shell
   git clone https://github.com/microsoft/MSMARCO-Document-Ranking
   ```

9. **Evaluate the Results**
   ```shell
   python MSMARCO-Document-Ranking/ms_marco_eval.py manticore_default_run.tsv
   ```
   The script outputs ranking metrics (e.g., MRR) to the console.

## Notes

* **Environment Variables**: Ensure `MANTICORE_PORT` in `.env` matches the port in docker-compose.yml (e.g., `29306:9306`).
* **Dataset Location**: The `datasets` directory is created during extraction and mounted to the Manticore container via `docker-compose.yml`.
* **Troubleshooting**:
  * If Manticore fails to connect, check the container logs (`docker logs manticore`) and verify the port and host settings.
  * Ensure the `datasets/msmarco-docdev-queries.tsv` file exists after extraction.

