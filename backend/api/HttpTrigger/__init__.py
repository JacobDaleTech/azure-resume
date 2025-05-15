import azure.functions as func
from azure.cosmos import CosmosClient
import os
import json

def main(req: func.HttpRequest) -> func.HttpResponse:
    try:
        # Get environment variables
        cosmos_uri = os.environ["COSMOS_DB_URI"]
        cosmos_key = os.environ["COSMOS_DB_KEY"]
        db_name = os.environ["COSMOS_DB_NAME"]
        container_name = os.environ["COSMOS_DB_CONTAINER"]

        # Connect to Cosmos DB
        client = CosmosClient(cosmos_uri, credential=cosmos_key)
        db = client.get_database_client(db_name)
        container = db.get_container_client(container_name)

        # Read the visitor count (assumes id = "1" and partition key = "1")
        item = container.read_item(item="1", partition_key="1")

        # Increment and update
        item["count"] += 1
        container.upsert_item(item)

        # Return JSON response
        return func.HttpResponse(
            json.dumps({"count": item["count"]}),
            mimetype="application/json",
            status_code=200
        )

    except Exception as e:
        # Return error response so it's not empty or HTML
        return func.HttpResponse(
            f"Function error: {str(e)}",
            status_code=500
        )
#Testing workflow again and again and again and again and again and again and again and again