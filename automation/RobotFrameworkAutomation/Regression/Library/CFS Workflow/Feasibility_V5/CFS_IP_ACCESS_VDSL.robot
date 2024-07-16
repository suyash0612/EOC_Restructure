*** Settings ***
Resource          ../../XML/xml.robot
Library           JSONLibrary
Library           String
Resource          ../../Json/json.robot
Resource          ../../Csv/csv.robot

*** Variables ***
${WORKSPACE}

*** Variables ***
@{actualToFeasibleBWMappingVDSL_Up}    1000    1100    1200    1300    1400    1500    1600    1700    1800    1900    2000    2500    3000    3500    4000    4500    5000
...               6000    7000    8000    9000    10000    12000    14000    16000    18000    20000    22000    24000    26000    28000    30000    # infotable for actualToFeasibleBWMappingVDSL_Up
@{actualToFeasibleBWMapingVDSL_Down}    10000    15000    20000    25000    30000    35000    40000    45000    50000    55000    60000    65000    70000    75000    80000    85000    90000
...               95000    100000    105000    115000    120000    125000    135000    140000    145000    160000    165000    170000    175000    180000    185000    190000    195000
...               200000    200000
# infotable for actualToFeasibleBWMapingVDSL_Down
&{MARGIN}         DOWNSTREAM_BANDWIDTH_MARGIN=2    UPSTREAM_BANDWIDTH_MARGIN=2    # margin to be subtracted from actual BW
&{DeliverTimeVDSL}    1=8    2=23

*** Keywords ***
Validate Available Copper Line
    [Arguments]    ${acpeResponse}    ${sqmResponse}
    [Documentation]    Validate Available Copper Line type of Place container
    #Get NL1 Lines value for this copper connection
    ${nl1Lines}    Get value from JSON    ${acpeResponse}    $.addressAvailabilities[?(@.carrierType=='Copper')].lineInformations[0].nl1
    #Get NL2 Lines value for this copper connection
    ${nl2Lines}    Get value from JSON    ${acpeResponse}    $.addressAvailabilities[?(@.carrierType=='Copper')].lineInformations[0].nl2
    #Get expected delivery days
    ${nlType}    Set Variable If    ${nl1Lines[0]} > 0    1    2
    ${expectedDeliveryDaysCSV}=    Get File    ${WORKSPACE}/TestData/SQM_IP_ACCESS/TC/expectedDeliveryDays.csv
    #Get Expected Delivery Days Based on nl type
    ${filteredRow}    Get expectedDeliveryDays Row from CSV    ${nlType}    CFS_IP_ACCESS_WBA_VDSL    AvailableCopperLine    ${expectedDeliveryDaysCSV}
    ${expectedDeliverDays}    Set Variable    ${filteredRow[3]}
    #Get house number
    ${houseNum}    Get Value From Json    ${acpeResponse}    $.houseNumber
    ${houseNum}    convert to string    ${houseNum[0]}
    #Get ISRA Spec
    ${israSpec}    Get Value From Json    ${acpeResponse}    $.addressAvailabilities[?(@.carrierType=='Copper')].lineInformations[0].connectionPoint
    #Validate @type
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].service.place[0][@type]    AvailableCopperLine
    #Validate role
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].service.place[0][role]    connectionPointOption
    #Validate Postcode
    ${postCode}    Get Value From Json    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].service.place[0][postcode]
    JSON Validate Element by Value    ${acpeResponse}    $.zipCode    ${postCode[0].replace(" ","")}
    #Validate HouseNumber
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].service.place[0][houseNumber]    ${houseNum}
    #Validate ConnectionPointSpec
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].service.place[0][connectionPointIdentifier]    ${israSpec[0]}
    #Validate Expected Delivery Date
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].service.place[0][expectedDeliveryDays]    ${expectedDeliverDays}

Validate Existing Copper Line
    [Arguments]    ${acpeResponse}    ${sqmResponse}
    [Documentation]    Validate the place containers in the sqm response
    ...    -ExistingCopperLine
    #Get NL1 Lines value for this copper connection
    ${nl1Lines}    Get value from JSON    ${acpeResponse}    $.addressAvailabilities[?(@.carrierType=='Copper')].lineInformations[0].nl1
    #Get NL2 Lines value for this copper connection
    ${nl2Lines}    Get value from JSON    ${acpeResponse}    $.addressAvailabilities[?(@.carrierType=='Copper')].lineInformations[0].nl2
    #Get expected delivery days
    ${nlType}    Set Variable If    ${nl1Lines[0]} > 0    1    2
    #Get Expected Delivery Days Based on nl type
    ${expectedDeliveryDaysCSV}=    Get File    ${WORKSPACE}/TestData/SQM_IP_ACCESS/TC/expectedDeliveryDays.csv
    ${filteredRow}    Get expectedDeliveryDays Row from CSV    ${nlType}    CFS_IP_ACCESS_WBA_VDSL    ExistingCopperLine    ${expectedDeliveryDaysCSV}
    ${expectedDeliverDays}    Set Variable    ${filteredRow[3]}
    Comment    ${expectedDeliverDays}    Set Variable    ${DeliverTimeVDSL}[${nlType}]
    #Get house number
    ${houseNum}    Get Value From Json    ${acpeResponse}    $.houseNumber
    ${houseNum}    convert to string    ${houseNum[0]}
    #Get ISRA Spec
    ${israSpec}    Get Value From Json    ${acpeResponse}    $.addressAvailabilities[?(@.carrierType=='Copper')].lineInformations[0].connectionPoint
    #Get Acess Service ID
    ${accessServiceId}    Get Value From Json    ${acpeResponse}    $.addressAvailabilities[?(@.carrierType=='Copper')].lineInformations[0].services[0].serviceId
    #Validate @type
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].service.place[?(@.accessServiceId)][@type]    ExistingCopperLine
    #Validate role
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].service.place[?(@.accessServiceId)][role]    connectionPointOption
    #Validate Postcode
    ${postCode}    Get Value From Json    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].service.place[0][postcode]
    JSON Validate Element by Value    ${acpeResponse}    $.zipCode    ${postCode[0].replace(" ","")}
    #Validate HouseNumber
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].service.place[?(@.accessServiceId)][houseNumber]    ${houseNum}
    #Validate ConnectionPointSpec
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].service.place[?(@.accessServiceId)][connectionPointIdentifier]    ${israSpec[0]}
    #Validate Expected Delivery Date
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].service.place[?(@.accessServiceId)][expectedDeliveryDays]    ${expectedDeliverDays}
    #Validate Access Service ID
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].service.place[?(@.accessServiceId)].accessServiceId    ${accessServiceId[0]}
    #Validate Patchless Possible
    ${false}    Convert To Boolean    False
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name=='CFS_IP_ACCESS_WBA_VDSL')].service.place[?(@.accessServiceId)].patchlessPossible    ${false}

Calculate ACPE Feasible Bandwidth VDSL
    [Arguments]    ${marginBW}    ${sqmResponse}    @{list}
    [Documentation]    Returns the Feasible bandwidth for VDSL based on a logic which subtracts a margin bandwidth
    ${i_distance}    Evaluate    abs(${list}[0]-${marginBW})
    ${index}    Set Variable    0
    FOR    ${item}    IN    @{list}
        log    ${item}
        log    ${marginBW}
        Continue For Loop If    ${item} > ${marginBW}
        ${bw_difference}    Evaluate    abs(${item}-${marginBW})
        ${feasibleBW}    Set Variable If    ${bw_difference} < ${i_distance}    ${item}    ${list}[0]
        ${i_distance}    Set Variable If    ${bw_difference} < ${i_distance}    ${bw_difference}    ${i_distance}
    END
    [Return]    ${feasibleBW}

Validate ACPE Feasible Bandwidth VDSL
    [Arguments]    ${acpeResponse}    ${sqmResponse}
    [Documentation]    Returns the Feasible bandwidth for VDSL based on a logic which subtracts a margin bandwidth
    #Get Actual bandwidth Down
    ${actualBW_Down}    Get Value From Json    ${acpeResponse}    $.addressAvailabilities[?(@.carrierType=='Copper')].maxBandwithDownOriginal
    log    ${MARGIN}[DOWNSTREAM_BANDWIDTH_MARGIN])
    ${actualBW_Down}    Evaluate    ${actualBW_Down[0]}/1024
    ${actualBW_Down}    Evaluate    ${actualBW_Down}-(${actualBW_Down}/100*${MARGIN}[DOWNSTREAM_BANDWIDTH_MARGIN])
    ${actualBW_Up}    Get Value From Json    ${acpeResponse}    $.addressAvailabilities[?(@.carrierType=='Copper')].maxBandwithUpOriginal
    log    ${MARGIN}[DOWNSTREAM_BANDWIDTH_MARGIN])
    ${actualBW_Up}    Evaluate    ${actualBW_Up[0]}/1024
    ${actualBW_Up}    Evaluate    ${actualBW_Up}-(${actualBW_Up}/100*${MARGIN}[UPSTREAM_BANDWIDTH_MARGIN])
    #Calculate Feasible Bandwidths
    ${feasibleBW_Down}    Calculate ACPE Feasible Bandwidth VDSL    ${actualBW_Down}    ${sqmResponse}    @{actualToFeasibleBWMapingVDSL_Down}
    ${feasibleBW_Up}    Calculate ACPE Feasible Bandwidth VDSL    ${actualBW_Up}    ${sqmResponse}    @{actualToFeasibleBWMappingVDSL_Up}
    #Validate Feasible bandwidth in SQM response
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name =='CFS_IP_ACCESS_WBA_VDSL')].service.serviceCharacteristic[?(@.name =='bandwidthDown')].value    ${feasibleBW_Down}
    JSON Validate Element by Value    ${sqmResponse}    $.serviceQualificationItem[?(@.service.name =='CFS_IP_ACCESS_WBA_VDSL')].service.serviceCharacteristic[?(@.name =='bandwidthUp')].value    ${feasibleBW_Up}
