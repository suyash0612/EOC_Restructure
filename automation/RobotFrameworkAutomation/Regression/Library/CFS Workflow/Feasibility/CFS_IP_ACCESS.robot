*** Settings ***
Resource          ../../XML/xml.robot
Library           JSONLibrary
Library           String
Resource          ../../Json/json.robot
Resource          ../../Csv/csv.robot

*** Keywords ***
Validate Address List
    [Arguments]    ${AddressList}    ${sqmResponse}
    [Documentation]    Validates Alternate Installation Address of a GeographicAddress
    #Get the number of alternative address tags
    ${size}    Get Length    ${AddressList}
    FOR    ${INDEX}    IN RANGE    0    ${size}
    #Get Place from SQM Response
        ${place}    Get Value From Json    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name == 'CFS_IP_ACCESS')].service.place[${INDEX}]
    #validate role
        Should Be Equal As Strings    ${place[0]}[role]    alternateInstallationAddress
    #Validate Type
        Should Be Equal As Strings    GeographicAddress    ${place[0]}[@type]
    #Validate Postcode
        XML Validate Element by Value    ${AddressList[${INDEX}]}    //addresslist/zipcode/text()    ${place[0]}[postcode]
    #Validate House Number
        XML Validate Element by Value    ${AddressList[${INDEX}]}    //addresslist/housenumber/text()    ${place[0]}[houseNumber]
    #Validate House Number Extension
        Run Keyword And Ignore Error    XML Validate Element by Value    ${AddressList[${INDEX}]}    //addresslist/housenrext/text()    ${place[0]}[houseNumberExtension]
    END

Validate Geographic Address
    [Arguments]    ${fpiResponse}    ${sqmResponse}
    [Documentation]    Get all the vendors in the FPI response
    ${carrierVendors}    Evaluate Xpath    ${fpiResponse}     //carriervendor
    ${size}    Get Length    ${carrierVendors}
    FOR    ${INDEX}    IN RANGE    0    ${size}
        ${AddressList}    Evaluate Xpath    ${carrierVendors[${INDEX}]}    //addresslist
        Validate Address List    ${AddressList}    ${sqmResponse}
    END
