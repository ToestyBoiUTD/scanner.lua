local SCAN_RADIUS = 10

-- The block tag to search for when scanning.
local BLOCK_TARGET_TAG = "forge:ores/diamond"

-- The cooldown time for the pulse scanner.
local PULSE_COOLDOWN = 2

-- Whether to use the `PULSE_COOLDOWN` or the `scanner.getScanCooldown()` function value for the pulse cooldown time.
local MANUAL_PULSE_COOLDOWN = true

function printHeader(scanner)
    -- Clear the screen
    term.clear()
    term.setCursorPos(1, 1)

    -- Get the fuel levels
    local infFuelLevel = 2147483647
    local fuelLevel = scanner.getFuelLevel()
    local maxFuelLevel = scanner.getMaxFuelLevel()

    if (fuelLevel == infFuelLevel) and (maxFuelLevel == infFuelLevel) then
        print("Fuel: Inf")
    else
        print("Fuel: " .. scanner.getFuelLevel() .. " / " .. scanner.getMaxFuelLevel())
    end

    print("Target Tag: " .. BLOCK_TARGET_TAG)
    print("Scan Radius: " .. SCAN_RADIUS)
    print("")
end

function calc3dDistance(x1, y1, z1, x2, y2, z2)
    local dx = x2 - x1
    local dy = y2 - y1
    local dz = z2 - z1
    return math.sqrt(dx*dx + dy*dy + dz*dz)
end

function calc1dDistance(x1, x2)
    return math.abs(x2 - x1)
end

function scanForNearestOre(scanner, radius)
    -- Enter the scan loop
    local continueScan = true
    local closestName = "None"
    local closestDist = math.huge
    local closestX = math.huge
    local closestY = math.huge
    local closestZ = math.huge
    while continueScan do
        -- Clear the screen
        term.clear()
        term.setCursorPos(1, 1)

        -- Print the header
        printHeader(scanner)

        -- Get the scanner data
        local scannerData, scanError = scanner.scan(radius)

        -- Check if the scanner data is nil
        if scannerData == nil then
            -- Report error
            print("An error occured: " .. scanError .. "\n")
        else
            -- Loop through the scanner data
            local noOreFound = true
            for i, data in ipairs(scannerData) do
                -- Check for fields
                if data.name and data.x and data.y and data.z and data.tags then
                    -- Check if the tag matches
                    if stringInTable(BLOCK_TARGET_TAG, data.tags) then
                        -- Calculate the distance
                        local newDist = calc3dDistance(0, 0, 0, data.x, data.y, data.z)

                        -- Check if the distance is closer
                        if newDist <= closestDist then
                            -- Update the closest data
                            closestName = data.name:match("([^:]+)$")
                            closestDist = newDist
                            closestX = data.x
                            closestY = data.y
                            closestZ = data.z

                            -- Found ore
                            noOreFound = false

                            -- Exit the loop
                            break
                        end
                    end
                end
            end

            -- Nothing found
            if noOreFound then
                closestName = "No ore found."
                closestDist = math.huge
                closestX = math.huge
                closestY = math.huge
                closestZ = math.huge
            end
        end

        -- Print the ore data
        print("Ore: " .. closestName)
        print("X: " .. calc1dDistance(0, closestX))
        print("Y: " .. calc1dDistance(0, closestY))
        print("Z: " .. calc1dDistance(0, closestZ))

        -- Check if manual cooldown
        if MANUAL_PULSE_COOLDOWN then
            -- Wait for the cooldown time
            os.sleep(PULSE_COOLDOWN)
        end
    end
end

local scanner = peripheral.find("geoscanner") -- get the geoscanner of the pocket computer
local continue = true
while continue do --
  printHeader(scanner)
  print("[d] for diamonds.")
  print("[n] for netherite.")
  local event, key = os.pullEvent("key")
  if key = keys.d then
    continue = false
    BLOCK_TARGET_TAG = "forge:ores/diamond"
  else if key = keys.n then
    continue = false
    BLOCK_TARGET_TAG = "forge:ores/netherite_scrap"
        else
            term.clear()
            term.setCursorPos(1,1)
            print("error please choose diamonds or netherite")
