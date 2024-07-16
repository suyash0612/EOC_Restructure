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
@{actualToFeasibleBWMappingVDSL_Up}    1000    1100    1200    1300    1400    1500    1600    1700    1800    1900    2000    2500    3000    3500    4000    4500    5000
...               6000    7000    8000    9000    10000    12000    14000    16000    18000    20000    22000    24000    26000    28000    30000    # infotable for actualToFeasibleBWMappingVDSL_Up
@{actualToFeasibleBWMapingVDSL_Down}    10000    20000    30000    40000    50000    60000    70000    80000    90000    100000    120000    140000    160000    170000    180000    190000    200000
...               # infotable for actualToFeasibleBWMapingVDSL_Down
&{MARGIN}         DOWNSTREAM_BANDWIDTH_MARGIN=2    UPSTREAM_BANDWIDTH_MARGIN=2    # margin to be subtracted from actual BW
&{DeliverTimeVDSL}    1=8    2=23

*** Keywords ***
Validate Available Copper Line
    [Arguments]    ${cipResponse}    ${sqmResponse}
    [Documentation]    Validate Available Copper Line type of Place container
    #Get Copper Connections
    ${copperConns}    Evaluate Xpath    ${cipResponse}    //connectionpointinfo/copperconnection[future-typeofconnection = '0']
    #Get NL1 Lines value for this copper connection
    ${nl1Lines}    Evaluate Xpath    ${cipResponse}    //connectionpointinfo/number-of-nl1-lines/text()
    ${nl2Lines}    Evaluate Xpath    ${cipResponse}    //connectionpointinfo/number-of-nl2-lines/text()
    Run Keyword If    "${nl2Lines[0]}" == "${EMPTY}"    Should Not Be Empty    ${copperConns}    No Available Copper Lines
    Log    ${copperConns}[0].future-typeofconnection
    ${nlType}    Set Variable If    "${nl1Lines[0]}" == "${EMPTY}"    2    1
    #Get expected delivery days
    #Get Expected Delivery Days Based on nl type
    ${expectedDeliveryDaysCSV}=    Get File    ${WORKSPACE}/TestData/SQM_IP_ACCESS/TC/expectedDeliveryDays.csv
    ${filteredRow}    Get expectedDeliveryDays Row from CSV    ${nlType}    CFS_IP_ACCESS_WBA_VDSL    AvailableCopperLine    ${expectedDeliveryDaysCSV}
    ${expectedDeliverDays}    Set Variable    ${filteredRow[3]}
    #Get house number
    ${houseNum}    Evaluate Xpath    ${cipResponse}    //enduserinfo/requested-housenumber/text()
    #Get ISRA Spec
    ${israSpec}    Evaluate Xpath    ${cipResponse}    //connectionpointinfo/isra-specs/text()
    #Validate @type
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].service.place[0][@type]    AvailableCopperLine
    #Validate role
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].service.place[0][role]    connectionPointOption
    #Validate Postcode
    ${postCode}    Get Value From Json    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].service.place[0][postcode]
    XML Validate Element by Value    ${cipResponse}    //enduserinfo/requested-zipcode/text()    ${postCode[0].replace(" ","")}
    #Validate HouseNumber
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].service.place[0][houseNumber]    ${houseNum[0]}
    #Validate ConnectionPointSpec
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].service.place[0][connectionPointIdentifier]    ${israSpec[0]}
    #Validate Expected Delivery Date
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].service.place[0][expectedDeliveryDays]    ${expectedDeliverDays}

Validate Existing Copper Line
    [Arguments]    ${cipResponse}    ${sqmResponse}
    [Documentation]    Validate the place containers in the sqm response
    ...    -ExistingCopperLine
    #Get Connections point info Tag information
    ${connPtInfo}    Evaluate Xpath    ${cipResponse}    //connectionpointinfo/copperconnection
    #Get Copper Connections
    ${copperConns}    Evaluate Xpath    ${cipResponse}    //connectionpointinfo/copperconnection[current-typeofconnection != '0']
    #Get house number
    ${houseNum}    Evaluate Xpath    ${cipResponse}    //enduserinfo/requested-housenumber/text()
    #Get ISRA Spec
    ${israSpec}    Evaluate Xpath    ${cipResponse}    //connectionpointinfo/isra-specs/text()
    ${size}    Get Length    ${copperConns}
    FOR    ${INDEX}    IN RANGE    1    ${size}
        ${mdfAccessServiceId}    Evaluate Xpath    ${copperConns[${INDEX}]}    //copperconnection[${INDEX}]/current-xdf-access-serviceid/text()
    #Validate @type
        JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].service.place[${INDEX}][@type]    ExistingCopperLine
    #Validate role
        JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].service.place[${INDEX}][role]    connectionPointOption
    #Validate Postcode
        ${postCode}    Get Value From Json    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].service.place[${INDEX}][postcode]
        XML Validate Element by Value    ${cipResponse}    //enduserinfo/requested-zipcode/text()    ${postCode[0].replace(" ","")}
    #Validate HouseNumber
        JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].service.place[${INDEX}][houseNumber]    ${houseNum[0]}
    #Validate ConnectionPointSpec
        JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].service.place[${INDEX}][connectionPointIdentifier]    ${israSpec[0]}
    #Validate mdfAccessServiceId
        JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].service.place[${INDEX}][mdfAccessServiceId]    ${mdfAccessServiceId[0]}
    END

Calculate Feasible Bandwidth VDSL
    [Arguments]    ${marginBW}    ${sqmResponse}    @{list}
    [Documentation]    Returns the Feasible bandwidth for VDSL based on a loic which subtracts a margin bandwidth
    ${i_distance}    Evaluate    abs(@{list}[0]-${marginBW})
    ${index}    Set Variable    0
    FOR    ${item}    IN    @{list}
        Continue For Loop If    ${item} > ${marginBW}
        ${bw_difference}    Evaluate    abs(${item}-${marginBW})
        ${feasibleBW}    Set Variable If    ${bw_difference} < ${i_distance}    ${item}    @{list}[0]
        ${i_distance}    Set Variable If    ${bw_difference} < ${i_distance}    ${bw_difference}    ${i_distance}
    END
    [Return]    ${feasibleBW}

Validate Feasible Bandwidth VDSL
    [Arguments]    ${fpiResponse}    ${sqmResponse}    ${subTechType}
    [Documentation]    Returns the Feasible bandwidth for VDSL based on a loic which subtracts a margin bandwidth
    #Get Actual bandwidth Down
    ${actualBW_Down}    Evaluate Xpath    ${fpiResponse}    //technologyavailability[technology-type/text()="${subTechType}"]/bandwidth-down/text()
    ${actualBW_Down}    Evaluate    ${actualBW_Down[0]}-(${actualBW_Down[0]}/100*&{MARGIN}[DOWNSTREAM_BANDWIDTH_MARGIN])
    #Get Actual bandwidth Up
    ${actualBW_Up}    Evaluate Xpath    ${fpiResponse}    //technologyavailability[technology-type/text()="${subTechType}"]/bandwidth-up/text()
    ${actualBW_Up}    Evaluate    ${actualBW_Up[0]}-(${actualBW_Up[0]}/100*&{MARGIN}[UPSTREAM_BANDWIDTH_MARGIN])
    #Calculate Feasible Bandwidths
    ${feasibleBW_Down}    Calculate Feasible Bandwidth VDSL    ${actualBW_Down}    ${sqmResponse}    @{actualToFeasibleBWMapingVDSL_Down}
    ${feasibleBW_Up}    Calculate Feasible Bandwidth VDSL    ${actualBW_Up}    ${sqmResponse}    @{actualToFeasibleBWMappingVDSL_Up}
    #Validate Feasible bandwidth in SQM response
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name =='CFS_IP_ACCESS_WBA_VDSL')].service.serviceCharacteristic[?(@.name =='bandwidthDown')].value    ${feasibleBW_Down}
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name =='CFS_IP_ACCESS_WBA_VDSL')].service.serviceCharacteristic[?(@.name =='bandwidthUp')].value    ${feasibleBW_Up}
