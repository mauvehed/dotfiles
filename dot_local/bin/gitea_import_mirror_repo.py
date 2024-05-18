import requests
import json

# This script will read all of your public and private repositories from the
# associated GitHub account and then create new repositories that are set to
# mirror from GitHub into your Gitea server.
#
# See here for more info on repository mirrors: https://docs.gitea.com/usage/repo-mirror
#
#############################################################################
# USE AT YOUR OWN RISK -- THIS SCRIPT WILL DELETE PRIVATE REPOS BEFORE COPY #
#############################################################################

# Configuration
GITHUB_API_URL = "https://api.github.com/user/repos"
GITEA_API_URL = "http://<your-gitea-instance>/api/v1"
GITHUB_TOKEN = "your_github_token"
GITEA_TOKEN = "your_gitea_token"
GITEA_USER_ID = your_gitea_user_id  # Replace with your actual user ID
GITEA_USERNAME = "your_gitea_username"  # Replace with your Gitea username
GITHUB_USERNAME = "your_github_username"

# Headers for GitHub and Gitea
github_headers = {
    "Authorization": f"token {GITHUB_TOKEN}",
    "Accept": "application/vnd.github.v3+json"
}

gitea_headers = {
    "Authorization": f"token {GITEA_TOKEN}",
    "Content-Type": "application/json"
}

# Step 1: Get all GitHub repositories
def get_github_repos():
    repos = []
    page = 1
    while True:
        response = requests.get(f"{GITHUB_API_URL}?page={page}&per_page=100", headers=github_headers)
        if response.status_code != 200:
            raise Exception(f"Failed to fetch GitHub repositories: {response.text}")
        page_repos = response.json()
        if not page_repos:
            break
        repos.extend(page_repos)
        page += 1
    return repos

# Step 2: Delete existing private repository on Gitea
def delete_gitea_repo(repo_name):
    delete_url = f"{GITEA_API_URL}/repos/{GITEA_USERNAME}/{repo_name}"
    response = requests.delete(delete_url, headers=gitea_headers)
    if response.status_code == 204:
        print(f"Successfully deleted repository {repo_name} on Gitea")
    elif response.status_code == 404:
        print(f"Repository {repo_name} does not exist on Gitea")
    else:
        print(f"Failed to delete repository {repo_name} on Gitea: {response.text}")
    return response.status_code == 204 or response.status_code == 404

# Step 3: Add repositories to Gitea in mirror mode
def add_repos_to_gitea(repos):
    for repo in repos:
        repo_name = repo['name']
        clone_url = repo['clone_url']

        # If the repository is private, include the username and token in the URL
        if repo['private']:
            clone_url = clone_url.replace('https://', f'https://{GITHUB_USERNAME}:{GITHUB_TOKEN}@')
            # Delete existing repository if it exists
            if not delete_gitea_repo(repo_name):
                print(f"Failed to delete existing repository {repo_name} on Gitea. Skipping creation.")
                continue

        data = {
            "clone_addr": clone_url,
            "uid": GITEA_USER_ID,
            "repo_name": repo_name,
            "mirror": True,
            "private": repo['private'],  # Maintain the privacy setting
            "auth_username": "",  # Not needed when including credentials in the URL
            "auth_password": ""   # Not needed when including credentials in the URL
        }
        response = requests.post(f"{GITEA_API_URL}/repos/migrate", headers=gitea_headers, data=json.dumps(data))
        if response.status_code != 201:
            print(f"Failed to add repository {repo_name} to Gitea: {response.text}")
        else:
            print(f"Successfully added repository {repo_name} to Gitea")

# Main execution
if __name__ == "__main__":
    github_repos = get_github_repos()
    add_repos_to_gitea(github_repos)
