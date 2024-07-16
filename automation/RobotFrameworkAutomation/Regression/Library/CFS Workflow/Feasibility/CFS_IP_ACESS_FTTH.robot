*** Settings ***
Resource          ../../XML/xml.robot
Library           JSONLibrary
Library           String
Resource          ../../Json/json.robot
Resource          ../../Csv/csv.robot
Resource          ../../Data Order/dataorder.robot

*** Variables ***
${WORKSPACE}

*** Variables ***
&{actualToFeasibleBWMappingFTTH}    1000000=500000    524000=500000    220000=200000    100000=100000    51200=50000    100=100    # infotable for actualToFeasibleBWMappingFTTH
&{DeliveryTimeFTTH}    6=5    11=14    # nlType=expectedDeliveryDays - for FTTH

*** Keywords ***
Validate Feasible Bandwidth FTTH
    [Arguments]    ${fpiResponse}    ${sqmResponse}    ${subTechType}
    [Documentation]    Returns the Feasible bandwidth for VDSL based on a loic which subtracts a margin bandwidth
    #Get Actual bandwidth Down
    ${actualBW_Down}    Evaluate Xpath    ${fpiResponse}    //technologyavailability[technology-type/text()="${subTechType}"]/bandwidth-down/text()
    ${actualBW_Down}    Set Variable    ${actualBW_Down[0]}
    #Get Actual bandwidth Up
    ${actualBW_Up}    Evaluate Xpath    ${fpiResponse}    //technologyavailability[technology-type/text()="${subTechType}"]/bandwidth-up/text()
    ${actualBW_Up}    Set Variable    ${actualBW_Up[0]}
    #Calculate Feasible Bandwidths
    ${feasibleBW_Down}    Set Variable    &{actualToFeasibleBWMappingFTTH}[${actualBW_Down}]
    ${feasibleBW_Up}    Set Variable    &{actualToFeasibleBWMappingFTTH}[${actualBW_Up}]
    #Validate the calculated Feasible Bandwidth Against the BW returned in the Feasibility Response
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.serviceCharacteristic[?(@.name=='bandwidthDown')].value    ${feasibleBW_Down}
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.serviceCharacteristic[?(@.name=='bandwidthUp')].value    ${feasibleBW_Up}

Validate Available Fiber Line
    [Arguments]    ${cipResponse}    ${sqmResponse}
    [Documentation]    Validate Available Copper Line type of Place container
    #Get Copper Connections
    ${fiberConns}    Evaluate Xpath    ${cipResponse}    //fiberinfo/connectionpointinfo/fiberconnection[future-typeofconnection = '0']
    ${nlType}    Evaluate Xpath    ${cipResponse}    //fiberinfo/connectionpointinfo/nl-type/text()
    ${nlType}    Set Variable    ${nlType[0]}
    Should Not Be Empty    ${fiberConns}    No Available Fiber Lines
    #Get house number
    ${houseNum}    Evaluate Xpath    ${cipResponse}    //enduserinfo/requested-housenumber/text()
    #Get Expected Delivery Days Based on nl type
    ${expectedDeliveryDaysCSV}=    Get File    ${WORKSPACE}/TestData/SQM_IP_ACCESS/TC/expectedDeliveryDays.csv
    ${filteredRow}    Get expectedDeliveryDays Row from CSV    ${nlType}    CFS_IP_ACCESS_WBA_FTTH    AvailableFiberLine    ${expectedDeliveryDaysCSV}
    #Get Delivery Time
    ${expectedDeliverDays}    Set Variable    ${filteredRow[3]}
    #Validate @type
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.place[0][@type]    AvailableFiberLine
    #Validate role
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.place[0][role]    connectionPointOption
    #Validate Postcode
    ${postCode}    Get Value From Json    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.place[0][postcode]
    XML Validate Element by Value    ${cipResponse}    //enduserinfo/requested-zipcode/text()    ${postCode[0].replace(" ","")}
    #Validate HouseNumber
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.place[0][houseNumber]    ${houseNum[0]}
    #Validate ConnectionPointSpec
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.place[0][connectionPointIdentifier]    nvt
    #Validate nlType
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.place[0][nlType]    ${nlType}
    #Validate Expected Delivery Date
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.place[0][expectedDeliveryDays]    ${expectedDeliverDays}

Validate Existing Fiber Line
    [Arguments]    ${cipResponse}    ${sqmResponse}
    [Documentation]    Validate the place containers in the sqm response
    ...    -AvailableCopperLine
    ...    -ExistingCopperLine
    #Get Copper Connections
    ${fiberConns}    Evaluate Xpath    ${cipResponse}    //fiberinfo/connectionpointinfo/fiberconnection[current-typeofconnection = '5']
    #Get house number
    ${houseNum}    Evaluate Xpath    ${cipResponse}    //enduserinfo/requested-housenumber/text()
    ${size}    Get Length    ${fiberConns}
    FOR    ${INDEX}    IN RANGE    0    ${size}
    #Get odfAccessServiceId
        ${odfAccessServiceId}    Evaluate Xpath    ${fiberConns[${INDEX}]}    //fiberconnection/current-xdf-access-serviceid/text()
    #Validate @type
        JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.place[${INDEX}][@type]    ExistingFiberLine
    #Validate role
        JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.place[${INDEX}][role]    connectionPointOption
    #Validate Postcode
        ${postCode}    Get Value From Json    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].service.place[${INDEX}][postcode]
        XML Validate Element by Value    ${cipResponse}    //enduserinfo/requested-zipcode/text()    ${postCode[0].replace(" ","")}
    #Validate HouseNumber
        JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.place[${INDEX}][houseNumber]    ${houseNum[0]}
    #Validate ConnectionPointSpec
        JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.place[${INDEX}][connectionPointIdentifier]    nvt
    #Validate odfAccessServiceId
        JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_FTTH')].service.place[${INDEX}][odfAccessServiceId]    ${odfAccessServiceId[0]}
    END
