*** Settings ***
Library   ./decodebase64.py
Library   ./csvLibrary.py
Library   ./playAudio.py
Library   ./download.py
Library   ./capture_logs.py

*** Keywords ***
Decode Base64
    [Arguments]  ${value}
    ${decodedValue}  decode base64object  ${value}
    [Return]  ${decodedValue}

Get Selenium Browser Logs
    ${log}  get selenium browser log
    [Return]  ${log}

Verify Wav File
    [Arguments]  ${file}
    verify wav file existence  ${file}