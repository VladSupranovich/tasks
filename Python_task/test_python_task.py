import logging
import pytest
from sqlalchemy import create_engine

from python_task import DataBase


class TestPythonTask:
    @pytest.fixture
    def db_config(self):
        return {
            'db_user': 'test_user',
            'db_pass': 'test_pass',
            'db_host': 'localhost',
            'db_port': '5432',
            'db_name': 'test_db'
        }

    def test_connection_success(self, db_config, mocker):
        conn_mock = mocker.MagicMock()
        mocker.patch('python_task.create_engine', return_value=conn_mock)

        db = DataBase(**db_config)
        db.connection()

        assert db.connection == conn_mock
        logging.info.assert_called_once_with("Database connection established")

    def test_connection_failure(self, db_config, mocker):
        error_msg = "Test error"
        mocker.patch('your_module.create_engine', side_effect=Exception(error_msg))

        your_class = YourClass(**db_config)
        your_class.connection()

        assert your_class.conn is None
        logging.error.assert_called_once_with(f"Error while connecting to database: {error_msg}")