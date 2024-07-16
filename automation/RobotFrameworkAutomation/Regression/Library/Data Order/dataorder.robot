*** Settings ***
Library           Collections
Library           String
Library           OperatingSystem
Library           DatabaseLibrary

*** Keywords ***
Get Service Item
    [Arguments]    ${order}    ${itemCode}
    [Documentation]    Returns a CFS item for given input
    ${result}    Create List
    ${basketItems}    Set Variable    ${order['orderItems']}
    log  ${basketItems}
    ${orderItemLength}    Get Length    ${basketItems}
    FOR    ${INDEX}    IN RANGE    0    ${orderItemLength}
        ${basketItem}    Set Variable    ${basketItems}[${INDEX}]
        Run Keyword If    "${basketItem}[item][cfs]" == "${itemCode}"    Append To List    ${result}    ${basketItem}
    END
    log  ${result}[0][item]
    [Return]    ${result}[0][item]

Get Service sepecification
    [Arguments]    ${order}    ${itemCode}
    [Documentation]    Returns a RFS item for given input
    ${result}    Create List
    ${basketItems}    Set Variable    ${order['services']}
    ${orderItemLength}    Get Length    ${basketItems}
    FOR    ${INDEX}    IN RANGE    0    ${orderItemLength}
        ${basketItem}    Set Variable    ${basketItems}[${INDEX}]
        Run Keyword If    "${basketItem}[cfsSpecification]" == "${itemCode}"    Append To List    ${result}    ${basketItem}
    END
    log  ${result}
    [Return]    ${result}[0]

Get Service Item Related Entity
    [Arguments]    ${cfsItem}    ${relatedEntityName}
    [Documentation]    Returns related entity associated against the basket item
    [Timeout]
    Comment    ${result}    Create List
    ${result}    Create List
    Log    ${relatedEntityName}
    Log    ${cfsItem}
    ${relatedEntities}    Set Variable    ${cfsItem}[relatedEntities]
    ${relatedEntitiesLength}    Get Length    ${relatedEntities}
    #Loop
    FOR    ${INDEX}    IN RANGE    0    ${relatedEntitiesLength}
        ${relatedEntity}    Set Variable    ${relatedEntities}[${INDEX}]
        Log    "Related Entity info..."
        Log    ${relatedEntity}
        Log    ${relatedEntity}[type]
        Log    ${relatedEntityName}
        Run Keyword If    "${relatedEntity}[type]" == "${relatedEntityName}"    log    "Matching"
        ...    ELSE    log    "Not matching"
        Log    ${result}
        Run Keyword If    "${relatedEntity}[type]" == "${relatedEntityName}"    Append To List    ${result}    ${relatedEntity}
        ...    ELSE    Set Variable    ${empty}
    END
    [Return]    ${result}[0]

Get Order Related Party
    [Arguments]    ${order}    ${relatedPartyName}
    [Documentation]    Returns related party associated against the order
    [Timeout]
    ${result}    Create List
    ${relatedParties}    Set Variable    ${order}[relatedParties]
    ${relatedPartiesLength}    Get Length    ${relatedParties}
    #Loop
    FOR    ${INDEX}    IN RANGE    0    ${relatedPartiesLength}
        ${relatedParty}    Set Variable    ${relatedParties}[${INDEX}]
        Run Keyword If    "${relatedParty}[role]" == "${relatedPartyName}"    Append To List    ${result}    ${relatedParty}
    END
    [Return]    ${result}[0]

Get Service Item Characteristic
    [Arguments]    ${cfsItem}    ${charName}
    [Documentation]    Returns characteristic value from a CFS Item
    ${characteristics}    Set Variable    ${cfsItem}[serviceCharacteristics]
    ${characteristicsLength}    Get Length    ${characteristics}
    #Loop
    FOR    ${INDEX}    IN RANGE    0    ${characteristicsLength}
        ${characteristic}    Set Variable    ${characteristics}[${INDEX}]
        ${char}=    Run Keyword If    "${characteristic}[name]" == "${charName}"    Set Variable    ${characteristic}[value]
        ...    ELSE    Set Variable    ${empty}
        Exit For Loop If    "${char}" != "${empty}"
    END
    [Return]    ${char}

Get Resource Item
    [Arguments]    ${cfsParentItem}    ${resourceCode}
    [Documentation]    Returns a Resource item for given input
    ${result}    Create List
    ${basketItems}    Set Variable    ${cfsParentItem['resources']}
    ${orderItemLength}    Get Length    ${basketItems}
    FOR    ${INDEX}    IN RANGE    0    ${orderItemLength}
        ${basketItem}    Set Variable    ${basketItems}[${INDEX}]
        Run Keyword If    "${basketItem}[resourceSpecification]" == "${resourceCode}"    Append To List    ${result}    ${basketItem}
    END
    [Return]    ${result}[0]

Get Resource Item Characteristic
    [Arguments]    ${resourceItem}    ${charName}
    [Documentation]    Returns characteristic value from a Resource Item
    ${characteristics}    Set Variable    ${resourceItem}[resourceCharacteristics]
    ${characteristicsLength}    Get Length    ${characteristics}
    #Loop
    FOR    ${INDEX}    IN RANGE    0    ${characteristicsLength}
        ${characteristic}    Set Variable    ${characteristics}[${INDEX}]
        ${char}=    Run Keyword If    "${characteristic}[name]" == "${charName}"    Set Variable    ${characteristic}[value]
        Exit For Loop If    "${char}" != "None"
    END
    [Return]    ${char}

Get Service Item Related Party
    [Arguments]    ${cfsItem}    ${relatedPartyName}
    [Documentation]    Returns related party associated against the basket item
    [Timeout]
    ${result}    Create List
    ${relatedParties}    Set Variable    ${cfsItem}[relatedParties]
    ${relatedPartiesLength}    Get Length    ${relatedParties}
    #Loop
    FOR    ${INDEX}    IN RANGE    0    ${relatedPartiesLength}
        ${relatedParty}    Set Variable    ${relatedParties}[${INDEX}]
        Run Keyword If    "${relatedParty}[role]" == "${relatedPartyName}"    Append To List    ${result}    ${relatedParty}
    END
    [Return]    ${result}[0]

Get Rfs Item
    [Arguments]    ${cfsParentItem}    ${rfsCode}
    [Documentation]    Returns a RFS item for given input
    ${result}    Create List
    ${basketItems}    Set Variable    ${cfsParentItem}[services]
    ${orderItemLength}    Get Length    ${basketItems}
    FOR    ${INDEX}    IN RANGE    0    ${orderItemLength}
        ${basketItem}    Set Variable    ${basketItems}[${INDEX}]
        Run Keyword If    "${basketItem}[cfsSpecification]" == "${rfsCode}"    Append To List    ${result}    ${basketItem}
    END
    [Return]    ${result}[0]

Get Rfs Item Characteristic
    [Arguments]    ${rfsItem}    ${charName}
    [Documentation]    Returns characteristic value from a RFS Item
    ${characteristics}    Set Variable    ${rfsItem}[serviceCharacteristics]
    ${characteristicsLength}    Get Length    ${characteristics}
    #Loop
    FOR    ${INDEX}    IN RANGE    0    ${characteristicsLength}
        ${characteristic}    Set Variable    ${characteristics}[${INDEX}]
        ${char}=    Run Keyword If    "${characteristic}[name]" == "${charName}"    Set Variable    ${characteristic}[value]
        Exit For Loop If    "${char}" != "None"
    END
    [Return]    ${char}

Get Order Related Entity
    [Arguments]    ${order}    ${relatedEntityName}
    [Documentation]    Returns related entity associated against the order
    [Timeout]
    ${result}    Create List
    ${relatedEntities}    Set Variable    ${order}[relatedEntities]
    ${relatedEntityLength}    Get Length    ${relatedEntities}
    #Loop
    FOR    ${INDEX}    IN RANGE    0    ${relatedEntityLength}
        ${relatedEntity}    Set Variable    ${relatedEntities}[${INDEX}]
        Run Keyword If    "${relatedEntity}[type]" == "${relatedEntityName}"    Append To List    ${result}    ${relatedEntity}
    END
    [Return]    ${result}[0]

Service Item Related Entity Should Not Exist
    [Arguments]    ${cfsItem}    ${relatedEntityName}
    [Documentation]    Validates if for given service item and related entity name, there is no such related entity against to the service item with the same name
    ${result}    Create List
    ${relatedEntities}    Set Variable    ${cfsItem}[relatedEntities]
    ${relatedEntitiesLength}    Get Length    ${relatedEntities}
    #Loop
    FOR    ${INDEX}    IN RANGE    0    ${relatedEntitiesLength}
        ${relatedEntity}    Set Variable    ${relatedEntities}[${INDEX}]
        Run Keyword If    "${relatedEntity}[type]" == "${relatedEntityName}"    Append To List    ${result}    ${relatedEntity}
    END
    Should Be Empty    ${result}

Get Service Item Attribute
    [Arguments]    ${cfsItem}    ${attributeName}
    [Documentation]    Returns related attribute associated against the basket item
    [Timeout]
    ${result}    Create List
    ${attributes}    Set Variable    ${cfsItem}[attrs]
    ${attributesLength}    Get Length    ${attributes}
    #Loop
    FOR    ${INDEX}    IN RANGE    0    ${attributesLength}
        ${attribute}    Set Variable    ${attributes}[${INDEX}]
        Run Keyword If    "${attribute}[name]" == "${attributeName}"    Append To List    ${result}    ${attribute}
    END
    [Return]    ${result}[0]

Validate Service Item Site Contact
    [Arguments]    ${serviceSiteContact}    ${requestSiteContact}
    [Documentation]    Validates if Site Contact from Service matches the Site Contact received from a request
    #Convert Party Data
    log    ${serviceSiteContact}
    ${serviceSiteContactParty}    Evaluate    json.loads('${serviceSiteContact}[party]')    json
    Should be Equal    ${serviceSiteContactParty}[firstName]    ${requestSiteContact}[firstName]
    Should be Equal    ${serviceSiteContactParty}[lastName]    ${requestSiteContact}[lastName]
    Should be Equal    ${serviceSiteContactParty}[phoneNumber]    ${requestSiteContact}[phoneNumber]
    Should be Equal    ${serviceSiteContactParty}[alternatePhoneNumber]    ${requestSiteContact}[alternatePhoneNumber]
    Should be Equal    ${serviceSiteContactParty}[email]    ${requestSiteContact}[email]
