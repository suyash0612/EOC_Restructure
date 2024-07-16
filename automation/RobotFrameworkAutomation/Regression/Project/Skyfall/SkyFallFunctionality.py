import json

def get_imsi_msisdn(json_data, iccid):
    """
    Fetch IMSI and MSISDN for a given ICCID from the provided JSON data.

    Args:
        json_data (str or list): The JSON data as a string or list of dictionaries.
        iccid (str): The ICCID value to search for.

    Returns:
        dict: A dictionary containing IMSI and MSISDN, or an empty dictionary if not found.
    """

    try :
        # If json_data is a string, convert it to a list of dictionaries
        if isinstance(json_data, str):
            data = json.loads(json_data)
        elif isinstance(json_data, list):
            data = json_data
        else:
            raise TypeError("json_data must be a JSON-formatted string or a list of dictionaries.")


        for item in data:
            if item.get("name") == iccid:
                result = {
                    "IMSI": item.get("imsi"),
                    "MSISDN": item.get("msisdn")
                }
                return result

        return {}

    except Exception as e:
        return {"error": str(e)}



    