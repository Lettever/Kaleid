import requests
import vdf

def get_owned_games(steam_id, api_key):
    """
    Retrieve all games owned by a Steam user using the Steam Web API.
    
    :param steam_id: The Steam ID of the user.
    :param api_key: Your Steam Web API key.
    :return: A list of owned games, or None if the request fails.
    """
    url = "https://api.steampowered.com/IPlayerService/GetOwnedGames/v1/"
    params = {
        "key": api_key,
        "steamid": steam_id,
        "include_appinfo": 1,
        "include_played_free_games": 0
    }

    try:
        response = requests.get(url, params=params)
        if response.status_code == 200:
            data = response.json()
            return data.get("response", {}).get("games", [])
        else:
            print(f"Failed to fetch owned games. Status code: {response.status_code}")
            return None
    except Exception as e:
        print(f"An error occurred: {e}")
        return None

def get_player_achievements(steam_id, api_key, app_id):
    """
    Retrieve all achievements for a specific game and user using the Steam Web API.
    
    :param steam_id: The Steam ID of the user.
    :param api_key: Your Steam Web API key.
    :param app_id: The App ID of the game.
    :return: A list of achievements, or None if the request fails.
    """
    url = "https://api.steampowered.com/ISteamUserStats/GetPlayerAchievements/v1/"
    params = {
        "key": api_key,
        "steamid": steam_id,
        "appid": app_id,
        "l": "en"  # Language (optional, defaults to English)
    }

    try:
        response = requests.get(url, params=params)
        if response.status_code == 200:
            data = response.json()
            return data.get("playerstats", {}).get("achievements", [])
        else:
            print(f"Failed to fetch achievements. Status code: {response.status_code}")
            print(f"Response: {response.text}")
            return None
    except Exception as e:
        print(f"An error occurred: {e}")
        return None

def main():
    # Get the Steam app list
    #games = get_owned_games(76561199007976324, "68031C2E17E1375075694133009A334A")
    #games = [game for game in games if game["playtime_forever"] > 0]
    #
    #for game in games:
    #    print("appid:", game["appid"])
    #    print("name:", game["name"])
    #    print("playtime_forever:", game["playtime_forever"])
    #    print("rtime_last_played:", game["rtime_last_played"])
    #    print()
    #print(len(games))
    
    ach = get_player_achievements(76561199007976324, "68031C2E17E1375075694133009A334A",764790)
    print([(r["name"], r["unlocktime"]) for r in ach])

if __name__ == "__main__":
    main()
