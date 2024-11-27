*** Settings ***
Library           JSONLibrary
Library           jsonlib.py

*** Keywords ***
JSON Validate Element by Value
    [Arguments]    ${json}    ${jPath}    ${expectedValue}
    [Documentation]    For a given JSON and JsonPath validates the content against a given value
    ${jsonValue}    Get Value From Json    ${json}    ${jPath}
    ${valueLength}    Get Length    ${jsonValue}
    Run Keyword If    "${valueLength}" > "0"    Should Be Equal    ${jsonValue[0]}    ${expectedValue}
    ...    ELSE    Run Keyword If    "${expectedValue}" == "${empty}"    Should be empty    ${expectedValue}
    ...    ELSE    Run Keyword If    "${expectedValue}" != "None"    fail    Mismatch between source and expected value

JSON Get Element
    [Arguments]    ${json}    ${jsonPath}
    [Documentation]    Returns JSON element for given path
    [Timeout]
    ${jsonValue}    Get Value From Json    ${json}    ${jsonPath}
    ${valueLength}    Get Length    ${jsonValue}
    Run Keyword If    "${valueLength}" == "0"    fail    No element found for ${jsonPath}
    [Return]    ${jsonValue}[0]

JSON Get Value From JsonString
    [Arguments]    ${json}    ${jPath}
    ${jsonValue}  Get Value From Jsonstring    ${json}    ${jPath}
    [Return]  ${jsonValue}

Get Value From Json And Compare Result
    [Arguments]    ${json}    ${jPath}    ${expectedValue}
    ${status}  Get Value From Json And Compare    ${json}    ${jPath}    ${expectedValue}
    Run Keyword If  '${status}' == 'False'  Fail  Value Mismatch
    Run Keyword If  '${status}' == 'True'  Log  Value Matched

Update Value In Json
    [Arguments]    ${json}    ${jPath}    ${value}
    ${json}  Update Value In Json For Jsonpath    ${json}    ${jPath}    ${value}
    Log  ${json}
    [Return]  ${json}