from pydantic import BaseModel


class Database(BaseModel):
    host: str
    port: int
    dbname: str
    user: str
    password: str

    def get_connection_str(self) -> str:
        return (
            f"host='{self.host}' "
            f"port='{self.port}' "
            f"dbname='{self.dbname}' "
            f"user='{self.user}' "
            f"password='{self.password}'"
        )
