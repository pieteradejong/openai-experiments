import os

class Config:
    OPENAI_API_KEY = os.getenv('OPENAI_API_KEY')
    OPENAI_ORG_ID = os.getenv('OPENAI_ORG_ID')


    if not OPENAI_API_KEY:
        raise ValueError("OPENAI_API_KEY environment variable is missing.")
    
    if not OPENAI_ORG_ID:
        raise ValueError("OPENAI_ORG_ID environment variable is missing.")

