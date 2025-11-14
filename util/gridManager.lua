local GridManager = {}
GridManager.__index = GridManager

function GridManager:new(mapMetaPath, mapImagePath, screenW, screenH)
    local meta = require(mapMetaPath)
    local image = love.graphics.newImage(mapImagePath)

    local self = setmetatable({}, GridManager)
    self.meta = meta
    self.image = image
    
    self.cols = meta.grid_dims.cols
    self.rows = meta.grid_dims.rows
    self.cellW = meta.cell.w
    self.cellH = meta.cell.h
    self.gridStartX = meta.grid_offset.x
    self.gridStartY = meta.grid_offset.y
    
    local imgW, imgH = image:getDimensions()
    local imgRatio = imgW / imgH
    local screenRatio = screenW / screenH

    local scale
    if imgRatio > screenRatio then
        -- Image is wider than screen → fit to width
        scale = screenW / imgW
    else
        -- Image is taller → fit to height
        scale = screenH / imgH
    end

    self.scale = scale
    self.imgScaledW = imgW * scale
    self.imgScaledH = imgH * scale

    self.mapX = (screenW - self.imgScaledW) / 2
    self.mapY = (screenH - self.imgScaledH) / 2

    self.offsetX = self.mapX + self.gridStartX * self.scale
    self.offsetY = self.mapY + self.gridStartY * self.scale

    self.showGrid = true

    self.selectedCell = nil

    print(string.format("[DEBUG] scale=%.3f, map centered at (%.1f, %.1f)",
        self.scale, self.mapX, self.mapY))

    return self
end

function GridManager:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.image, self.mapX, self.mapY, 0, self.scale, self.scale)

    if self.showGrid then
        love.graphics.setColor(1, 1, 1, 0.25)

        local scaledCellW = self.cellW * self.scale
        local scaledCellH = self.cellH * self.scale

        -- Draw vertical grid lines
        for i = 0, self.cols do
            local x = self.offsetX + i * scaledCellW
            love.graphics.line(x, self.offsetY, x, self.offsetY + self.rows * scaledCellH)
        end

        -- Draw horizontal grid lines
        for j = 0, self.rows do
            local y = self.offsetY + j * scaledCellH
            love.graphics.line(self.offsetX, y, self.offsetX + self.cols * scaledCellW, y)
        end
    end

    -- Reset color
    love.graphics.setColor(1, 1, 1)

    -- Draw reachable movement cells
    if self.reachableCells then
        self:highlightCells(self.reachableCells, 0, 1, 0, 0.3)
    end

    -- Draw selected cell (red)
    if self.selectedCell then
        self:highlightCells({self.selectedCell}, 1, 0, 0, 0.4)
    end
end

function GridManager:highlightCells(cells, r, g, b, a)
    if not cells then return end
    r, g, b, a = r or 0, g or 1, b or 0, a or 0.3  -- default: green semi-transparent

    love.graphics.setColor(r, g, b, a)
    for _, cell in ipairs(cells) do
        local x, y = self:gridToScreen(cell.x, cell.y)
        local scaledCellW = self.cellW * self.scale
        local scaledCellH = self.cellH * self.scale
        love.graphics.rectangle("fill", x, y, scaledCellW, scaledCellH)
    end
    love.graphics.setColor(1, 1, 1, 1) -- reset
end


function GridManager:screenToGrid(mx, my)
    local scaledCellW = self.cellW * self.scale
    local scaledCellH = self.cellH * self.scale

    local gx = math.floor((mx - self.offsetX) / scaledCellW)
    local gy = math.floor((my - self.offsetY) / scaledCellH)

    if gx < 0 or gx >= self.cols or gy < 0 or gy >= self.rows then
        return nil
    end

    return gx, gy
end

function GridManager:gridToScreen(gx, gy)
    local scaledCellW = self.cellW * self.scale
    local scaledCellH = self.cellH * self.scale

    local x = self.offsetX + gx * scaledCellW
    local y = self.offsetY + gy * scaledCellH
    return x, y
end

function GridManager:onCellClicked(gx, gy)
    print("You clicked on cell:", gx, gy)
    -- Example: toggle terrain, move unit, open info panel, etc.
end

function GridManager:toggleGrid()
    self.showGrid = not self.showGrid
end

return GridManager
