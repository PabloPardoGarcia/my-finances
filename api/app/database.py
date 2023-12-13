import os

from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker

HOST = os.getenv("POSTGRES_HOST")
PORT = os.getenv("POSTGRES_PORT", default=5432)
USER = os.getenv("POSTGRES_USER")
PASSWORD = os.getenv("POSTGRES_PASSWORD")
DBNAME = os.getenv("POSTGRES_DB")
DATABASE_URL = f"postgresql://{USER}:{PASSWORD}@{HOST}:{PORT}/{DBNAME}"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()
