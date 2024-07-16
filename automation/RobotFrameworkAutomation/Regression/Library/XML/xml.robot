*** Settings ***
Library           XML    use_lxml=True
Library           String

*** Keywords ***
XML Validate Element by Value
    [Arguments]    ${xml}    ${xpath}    ${expectedValue}
    [Documentation]    For a given XML and XPath validates the content against a given value
    ${xmlValue}    Evaluate Xpath    ${xml}    ${xpath}
    ${valueLength}    Get Length    ${xmlValue}
    Run Keyword If    "${valueLength}" > "0"    Should Be Equal    ${xmlValue[0]}    ${expectedValue}
    ...    ELSE    Run Keyword If    "${expectedValue}" == "${empty}"    Should be empty    ${expectedValue}
    ...    ELSE    Run Keyword If    "${expectedValue}" != "None"    fail    Mismatch between source and expected value
