import pandas as pd
from sqlalchemy import create_engine, engine
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

rooms_file = 'Data//rooms.json'
students_file = 'Data//students.json'

class DataBase:
    def __init__(self,db_host, db_name, db_user, db_pass, db_port):
        self.db_host = db_host
        self.db_name = db_name
        self.db_user = db_user
        self.db_pass = db_pass
        self.db_port = db_port

    def connection(self):
        """ Connect to the PostgreSQL database """
        try:
            self.conn = create_engine(f'postgresql+psycopg2://{self.db_user}:{self.db_pass}@{self.db_host}:{self.db_port}/{self.db_name}')
            self.conn.connect()
            logging.info("Database connection established")
        except Exception as error:
            logging.error(f"Error while connecting to database: {error}")


    def write_file(self, table_name: 'rooms, students', file_path):
        """ Write json file into  PostgreSQL database """
        data = pd.read_json(file_path)
        try:
            data.to_sql(name=table_name, con=self.conn, if_exists='append', index=False)
            logging.info(f"Data inserted into {table_name} table")
        except Exception as error:
            logging.error(f"Error while inserting data into {table_name} table: {error}")


db = DataBase('localhost', 'python_task', 'postgres', '1996', '5432')
db.connection()

#db.write_file('rooms', rooms_file)
#db.write_file('students', students_file)

#db.write_file()