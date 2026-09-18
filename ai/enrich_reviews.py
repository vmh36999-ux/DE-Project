import os

import snowflake.connector
from google import genai
from pydantic import BaseModel
from dotenv import load_dotenv


# =========================================================
# 1. LOAD ENVIRONMENT VARIABLES
# =========================================================
load_dotenv(override=True)
# =========================================================
# 2. CONFIG
# =========================================================
MODEL = "gemini-3.6-flash"
SAMPLE_N = 5
TOPICS = [
    "food quality",
    "delivery",
    "pricing",
    "service",
    "packaging",
    "other",
]
# =========================================================
# 3. STRUCTURED OUTPUT SCHEMA
# =========================================================
class ReviewEnrichment(BaseModel):
    sentiment_label: str
    sentiment_score: float
    topic: str
    key_issue: str | None
# =========================================================
# 4. GEMINI CLIENT
# =========================================================
client = genai.Client(
    api_key=os.getenv("GEMINI_API_KEY")
)
# =========================================================
# 5. PROMPT
# =========================================================
SYSTEM_PROMPT = f"""
You classify customer reviews for a food delivery app.
For each review:
- sentiment_label: positive, negative, or neutral
- sentiment_score: a number between -1.0 and 1.0
- topic: one of {TOPICS}
- key_issue: a short phrase of at most 6 words,
  or null if there is no issue
Important:
- Choose exactly one topic from the allowed topic list.
- sentiment_score must be between -1.0 and 1.0.
- key_issue must be null when there is no clear issue.
"""
# =========================================================
# 6. SNOWFLAKE CONNECTION
# =========================================================
def get_connection():
    return snowflake.connector.connect(
        account=os.getenv("SNOWFLAKE_ACCOUNT"),
        user=os.getenv("SNOWFLAKE_USER"),
        password=os.getenv("SNOWFLAKE_PASSWORD"),
        database=os.getenv("SNOWFLAKE_DATABASE"),
        warehouse=os.getenv("SNOWFLAKE_WAREHOUSE"),
        schema=os.getenv("SNOWFLAKE_SCHEMA"),
        role=os.getenv("SNOWFLAKE_ROLE"),
    )
# =========================================================
# 7. CREATE OUTPUT TABLE
# =========================================================
def create_output_table(cursor):
    cursor.execute("""
        CREATE SCHEMA IF NOT EXISTS ZOMATO.AI
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS ZOMATO.AI.REVIEW_ENRICHED (
            REVIEW_ID STRING,
            SENTIMENT_LABEL STRING,
            SENTIMENT_SCORE FLOAT,
            TOPIC STRING,
            KEY_ISSUE STRING,
            MODEL STRING,
            ENRICHED_AT TIMESTAMP_LTZ
                DEFAULT CURRENT_TIMESTAMP()
        )
    """)
# =========================================================
# 8. READ REVIEWS THAT HAVE NOT BEEN ENRICHED
# =========================================================
def get_reviews_to_enrich(cursor, sample_n):
    cursor.execute(f"""
        SELECT
            r.REVIEW_ID,
            r.COMMENT
        FROM ZOMATO.RAW.REVIEWS r
        LEFT JOIN ZOMATO.AI.REVIEW_ENRICHED e
            ON r.REVIEW_ID = e.REVIEW_ID
        WHERE e.REVIEW_ID IS NULL
          AND r.COMMENT IS NOT NULL
        LIMIT {sample_n}
    """)

    return cursor.fetchall()
# =========================================================
# 9. CALL GEMINI
# =========================================================
def classify_review(comment: str) -> ReviewEnrichment:

    prompt = f"""
{SYSTEM_PROMPT}

Customer review:
{comment}
"""

    response = client.models.generate_content(
        model=MODEL,
        contents=prompt,
        config={
            "response_mime_type": "application/json",
            "response_schema": ReviewEnrichment,
        },
    )

    if response.parsed is None:
        raise RuntimeError(
            "Gemini did not return a structured result"
        )

    return response.parsed
# =========================================================
# 10. WRITE RESULTS
# =========================================================
def save_results(cursor, results):
    cursor.executemany(
        """
        INSERT INTO ZOMATO.AI.REVIEW_ENRICHED
        (
            REVIEW_ID,
            SENTIMENT_LABEL,
            SENTIMENT_SCORE,
            TOPIC,
            KEY_ISSUE,
            MODEL
        )
        VALUES (%s, %s, %s, %s, %s, %s)
        """,
        results,
    )
# =========================================================
# 11. MAIN PIPELINE
# =========================================================
def main():
    conn = get_connection()
    cursor = conn.cursor()
    try:
        # ---------------------------------------------
        # CREATE OUTPUT TABLE
        # ---------------------------------------------
        create_output_table(cursor)
        # ---------------------------------------------
        # READ
        # ---------------------------------------------
        reviews = get_reviews_to_enrich(
            cursor,
            SAMPLE_N
        )
        if not reviews:
            print("No new reviews to enrich.")
            return
        print(
            f"Found {len(reviews)} reviews to enrich."
        )
        # ---------------------------------------------
        # AI RESULTS
        # ---------------------------------------------
        results = []
        for review_id, comment in reviews:
            print(
                f"\nProcessing review {review_id}"
            )
            try:
                ai_result = classify_review(comment)
                print(
                    "AI result:",
                    ai_result
                )
                results.append(
                    (
                        review_id,
                        ai_result.sentiment_label,
                        ai_result.sentiment_score,
                        ai_result.topic,
                        ai_result.key_issue,
                        MODEL,
                    )
                )

            except Exception as e:

                print(
                    f"Failed to enrich review "
                    f"{review_id}: {e}"
                )

        # ---------------------------------------------
        # WRITE
        # ---------------------------------------------

        if results:

            save_results(
                cursor,
                results
            )

            conn.commit()

            print(
                f"\nSaved {len(results)} enriched reviews."
            )

    except Exception:

        conn.rollback()
        raise

    finally:

        cursor.close()
        conn.close()


# =========================================================
# 12. ENTRY POINT
# =========================================================

if __name__ == "__main__":
    main()