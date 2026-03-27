import os
import dotenv
from mcp_bakery_app import tools
from google.adk.agents import LlmAgent

dotenv.load_dotenv()

PROJECT_ID = os.getenv('GOOGLE_CLOUD_PROJECT', 'project_not_set')

maps_toolset = tools.get_maps_mcp_toolset()
bigquery_toolset = tools.get_bigquery_mcp_toolset()

root_agent = LlmAgent(
    model='gemini-3.1-pro-preview',
    name='fuel_agent',
    instruction=f"""
Help the user answer questions by strategically combining insights from two sources:

1. **BigQuery toolset:** 
Access petrol and diesel price data stored in the `petrol` dataset.
Use tables like fuel_prices, fuel_trends, fuel_consumption, and fuel_tax.
Do not use any other dataset.
Run all query jobs from project id: {PROJECT_ID}.

2. **Maps Toolset:** 
Use this for real-world location analysis, finding cities, nearby fuel stations,
and calculating travel routes between locations.
Include a hyperlink to an interactive map in your response where appropriate.
""",
    tools=[maps_toolset, bigquery_toolset]
)
