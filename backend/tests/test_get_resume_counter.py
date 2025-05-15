import os
import requests

def test_resume_counter():
    url = os.environ["AZURE_FUNCTION_URL"]
    response = requests.get(url)
    assert response.status_code == 200
    assert "count" in response.json()
