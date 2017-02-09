--[[
Copyright (c) 2016 "Enzojz" from www.transportfever.net
(https://www.transportfever.net/index.php/User/27218-Enzojz/)

Github repository:
https://github.com/Enzojz/transportfever

Anyone is free to use the program below, however the auther do not guarantee:
* The correctness of program
* The invariant of program in future

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including the right to distribute and without limitation the rights to use, copy and/or modify
the Software, and to permit persons to whom the Software is furnished to do so, subject to the
following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

--]]
local constructionutil = require "constructionutil"
local railstationconfigutil = require "railstationconfigutil"
local laneutil = require "laneutil"
local coor = require "coor"
local func = require "func"

local slopedstation = {}

local slopeList = {0, 10, 20, 25, 30, 35, 40, 50, 60}
local heightList = {-7.5, -5, -2.5, 0, 2.5, 5, 7.5}
local heightFactor = {0.5, 1, 2, 3, 4, 6}
local slopeRad = func.mapPair(
    func.concat(slopeList, func.map(slopeList, function(s) return -s end)),
    function(s) return s, math.atan(s * 0.001) end)
local slopeMRotX = func.mapValues(slopeRad, coor.rotX)
local slopeMRotY = func.mapValues(slopeRad, coor.rotY)

function slopedstation.addParams(params)
    params[#params + 1] =
        {
            key = "slope",
            name = _("Slope").."(‰)",
            values = func.map(slopeList, tostring),
            defaultIndex = 0
        }
    
    params[#params + 1] =
        {
            key = "isneg",
            name = _("Negative slope"),
            values = {_("No"), _("Yes")},
            defaultIndex = 0
        }
    
    params[#params + 1] =
        {
            key = "height",
            name = _("Altitude Adjustment").."(m)",
            values = func.map(heightList, tostring),
            defaultIndex = 3
        }
    params[#params + 1] =
        {
            key = "heightfactor",
            name = _("Altitude Adjustment multiple"),
            values = func.map(heightFactor, function(s) return _("x" .. s) end),
            defaultIndex = 1
        }
    return params
end

local function replaceMdl(originalMdl, slope)
    return slope == 0 and originalMdl or "sloped_station/" .. slope .. (string.gsub(originalMdl, [==[station/train(.+)]==], "%1"))
end

function slopedstation.updateFn(stationConfig, stationBuilding, platformConfig, params)
    
    local config = railstationconfigutil.makeTrainStationConfig(params, stationConfig, stationBuilding, platformConfig)
    local result = constructionutil.makeTrainStationNew(config)
    
    local isneg = {1, -1}
    
    local slope = isneg[params.isneg + 1] * slopeList[params.slope + 1]
    
    local ha = heightList[params.height + 1] * heightFactor[params.heightfactor + 1]
    
    local length = #config.platformConfig.firstPlatformParts * config.segmentLength
    
    local mz = coor.transZ(ha)
    local m = slopeMRotX[slope]
    
    local mapEdgeList = function(edgeList)
        local mapEdge = coor.applyEdge(m, m)
        local mapHeight = func.bind(coor.setHeight, ha)
        
        if (edgeList.type == "TRACK") then
            edgeList.edges = func.map(edgeList.edges, mapEdge)
        end
        edgeList.edges = func.map(edgeList.edges, mapHeight)
        return edgeList
    end
    
    result.edgeLists = func.map(result.edgeLists, mapEdgeList)
    local mapModel = function(model)
        if (model.id == config.stationBuilding or model.id == config.stairs) then
            model.id = replaceMdl(model.id, slope)
        end
        model.transf = coor.mul(model.transf, m, mz)
        return model
    end
    
    result.models = func.map(result.models, mapModel)
    
    local mapTerrainList = function(ta)
        local mapTerrain = function(t) return (coor.tuple2Vec(t) .. m * mz).toTuple() end
        local mapFaces = function(f) return func.map(f, mapTerrain) end
        ta.faces = func.map(ta.faces, mapFaces)
        return ta
    end
    result.terrainAlignmentLists = func.map(result.terrainAlignmentLists, mapTerrainList)
    
    return result
end

local mockPathPattern = [==[^@(.+)/sloped_station/(-?%d%d)/(.+%.mdl)$]==]

function slopedstation.extractModel(mockPath)
    local r = {}
    string.gsub(mockPath, mockPathPattern, function(m, s, b) r.path, r.slope = m .. "/station/train/" .. b, tonumber(s) end)
    return r.path, r.slope
end

function slopedstation.generalTreat(m, nodeMatch)
    return function(result)
            
            local function treat(keep, rotate)
                local kepPoint = keep.toTuple()
                local rotPoint = (rotate .. m).toTuple()
                local vec = {rotPoint[1] - kepPoint[1], 0, 0}
                return table.unpack(laneutil.makeLanes({{kepPoint, rotPoint, vec, vec, 1.5}}))
            end
            
            laneModifier = function(lane)
                local mode = table.unpack(lane.transportModes)
                if (mode == "PERSON" or mode == "CARGO") then
                    for i = 1, #lane.nodes, 2 do
                        local bgnNode = coor.edge2Vec(lane.nodes[i])
                        local endNode = coor.edge2Vec(lane.nodes[i + 1])
                        if (nodeMatch(endNode)) then
                            lane.nodes[i], lane.nodes[i + 1] = treat(bgnNode, endNode)
                        elseif (nodeMatch(bgnNode)) then
                            lane.nodes[i], lane.nodes[i + 1] = treat(endNode, bgnNode)
                        end
                    end
                end
                return lane
            end
            
            result.metadata.transportNetworkProvider.laneLists =
                func.map(result.metadata.transportNetworkProvider.laneLists, laneModifier)
            
            return result
    end
end

function slopedstation.treatBuilding(slope)
    
    local m = slopeMRotY[slope]
    local nodeMatch = function(pt) return (pt.x == 4.5 or pt.x == -4.5) and pt.y == -10.0 end
    
    return slopedstation.generalTreat(m, nodeMatch)
end


function slopedstation.treatStairs(slope)
    
    local m = slopeMRotX[-slope]
    local nodeMatch = function(pt) return (pt.y == 4.5 or pt.y == -4.5) and pt.x == 3.5 end
    
    return slopedstation.generalTreat(m, nodeMatch)
end

return slopedstation
