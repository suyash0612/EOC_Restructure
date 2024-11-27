import json
from jsonpath_ng.ext import parse  # Use jsonpath_ng.ext for extended features
from jsonpath_ng import jsonpath

def get_value_from_jsonstring(json_object, json_path):
    """
    Finds a value in the JSON data using a JSONPath and returns the extracted value(s).

    :param json_object: The JSON data as a string or dict.
    :param json_path: The JSONPath expression as a string.
    :return: A list of extracted values or an empty list if no values are found.
    """
    try:
        # Parse the json_object if it's a string
        if isinstance(json_object, str):
            json_object = json.loads(json_object)
        
        # Parse the JSONPath expression
        jsonpath_expression = parse(json_path)
        
        # Find all matches for the JSONPath
        matches = jsonpath_expression.find(json_object)
        
        # If no matches found, return an empty list
        if not matches:
            print(f"No matches found for the JSONPath: {json_path}")
            return []
        
        # Extract values from the matches
        extracted_values = [match.value for match in matches]
        return extracted_values
    
    except json.JSONDecodeError:
        print("Invalid JSON format.")
        return []
    except Exception as e:
        print(f"An error occurred: {e}")
        return []

def get_value_from_json_and_compare(json_object, json_path, value_to_compare):
    """
    Finds a value in the JSON data using a JSONPath, compares it with a given value, 
    and returns True if the comparison is successful, otherwise False with a reason printed.

    :param json_object: The JSON data as a string.
    :param json_path: The JSONPath expression as a string.
    :param value_to_compare: The value to compare against the extracted JSON values.
    :return: True if the comparison is successful, otherwise False.
    """
    try:
        # Parse the json_object if it's a string
        if isinstance(json_object, str):
            json_object = json.loads(json_object)
        
        # Parse the JSONPath expression
        jsonpath_expression = parse(json_path)
        
        # Find all matches for the JSONPath
        matches = jsonpath_expression.find(json_object)
        
        # If no matches found, print the reason and return False
        if not matches:
            print(f"No matches found for the JSONPath: {json_path}")
            return False
        
        # Extract values from the matches
        extracted_values = [match.value for match in matches]
        # print(f"Extracted Values: {extracted_values}")
        
        # Check if any extracted value matches the comparison value
        if any(val == str(value_to_compare) for val in extracted_values):
            print(f"Value is matched")
            return True
        else:
            print(f"No extracted value matches the comparison value: {value_to_compare}")
            return False
    
    except json.JSONDecodeError:
        print("Invalid JSON format.")
        return False
    except Exception as e:
        print(f"An error occurred: {e}")
        return False

import json
from jsonpath_ng.ext import parse  # Use jsonpath_ng.ext for extended features
from jsonpath_ng import jsonpath

def update_value_in_json_for_jsonpath(json_input, json_path, value):
    try:
        # Step 1: Parse the JSONPath expression
        jsonpath_expr = parse(json_path)
        print(f"Parsed JSONPath: {jsonpath_expr}")

        # Step 2: Find the matching location in the JSON
        matches = jsonpath_expr.find(json_input)
        print(f"Matches found: {matches}")

        if not matches:
            raise KeyError(f"Path not found: {json_path}")

        # Step 3: Update the found location(s) with the new value
        for match in matches:
            parent = match.context.value  # The parent object of the matched item
            print(f"Parent object: {parent}")

            # Handle if it's a field or index
            if isinstance(match.path, jsonpath.Fields):
                last_key = match.path.fields[0]
            else:
                last_key = match.path.index
            print(f"Key or index to update: {last_key}")

            # Update the value in the parent (dict or list)
            if isinstance(parent, list):
                parent[int(last_key)] = value
            else:
                parent[last_key] = value

        print(f"Updated JSON: {json_input}")
        return json_input
    
    except Exception as e:
        print(f"Error: {e}")