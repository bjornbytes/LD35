-------------------------------------------------------------------------------
-- Spine Runtimes Software License
-- Version 2.1
-- 
-- Copyright (c) 2013, Esoteric Software
-- All rights reserved.
-- 
-- You are granted a perpetual, non-exclusive, non-sublicensable and
-- non-transferable license to install, execute and perform the Spine Runtimes
-- Software (the "Software") solely for internal use. Without the written
-- permission of Esoteric Software (typically granted by licensing Spine), you
-- may not (a) modify, translate, adapt or otherwise create derivative works,
-- improvements of the Software or develop new applications using the Software
-- or (b) remove, delete, alter or obscure any trademarks or any copyright,
-- trademark, patent or other intellectual property or proprietary rights
-- notices on or in the Software, including any copy thereof. Redistributions
-- in binary or source form must include this license and terms.
-- 
-- THIS SOFTWARE IS PROVIDED BY ESOTERIC SOFTWARE "AS IS" AND ANY EXPRESS OR
-- IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
-- MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
-- EVENT SHALL ESOTERIC SOFTARE BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
-- SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
-- OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
-- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
-- OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-------------------------------------------------------------------------------

local AtlasPage = require 'lib/spine-lua/AtlasPage'
local AtlasRegion = require 'lib/spine-lua/AtlasRegion'

local Atlas = {}

function Atlas.new(path, textureLoader)
  local self = {
    textureLoader = textureLoader,
    pages = {},
    regions = {}
  }

  local page = nil

  local function getLine(str)
    local index = str:find('\n')
    if not index then return str, nil end
    local line = str:sub(1, index):gsub('^%s+', ''):gsub('%s+$', '')
    return line, str:sub(index + 1)
  end

  local function getValues(str)
    local line, str = getLine(str)
    local colon = line:find(':')
    if not colon then return end
    local chunk = line:sub(colon + 1)
    local t = {}
    chunk:gsub('%s*([^,]+),?', function(val) table.insert(t, val) end)
    return str, unpack(t)
  end

  local line, str = '', spine.utils.readFile(path)
  if not str then return nil end
  repeat
    line, str = getLine(str)
    if #line == 0 then
      page = nil
    elseif not page then
      page = AtlasPage.new()
      page.name = line
      str, page.width, page.height = getValues(str)
      str, page.format = getValues(str)
      str, page.minFilter, page.magFilter = getValues(str)

      local direction
      str, direction = getValues(str)
      page.uWrap, page.vWrap = 'none', 'none'
      if direction == 'xy' then page.uWrap, page.vWrap = 'repeat', 'repeat'
      elseif direction == 'x' then page.uWrap = 'repeat'
      elseif direction == 'y' then page.vWrap = 'repeat' end

      table.insert(self.pages, page)
    else
      local region = AtlasRegion.new()
      region.name = line
      region.page = page

      local rotate
      str, rotate = getValues(str)
      region.rotate = rotate == 'true'

      local x, y
      str, x, y = getValues(str)

      local width, height
      str, width, height = getValues(str)

      region.u, region.v = x / page.width, y / page.height
      if region.rotate then
        region.u2 = (x + height) / page.width
        region.v2 = (y + width) / page.height
      else
        region.u2 = (x + width) / page.width
        region.v2 = (y + height) / page.height
      end

      region.x, region.y, region.width, region.height = x, y, width, height

      str, region.originalWidth, region.originalHeight = getValues(str)
      str, region.offsetX, region.offsetY = getValues(str)
      str, region.index = getValues(str)

      for _, key in pairs({'x', 'y', 'width', 'height', 'originalWidth', 'originalHeight', 'offsetX', 'offsetY', 'index'}) do
        region[key] = tonumber(region[key])
      end

      table.insert(self.regions, region)
    end
  until not str:find('\n')

  function self:findRegion(name)
    for i, region in ipairs(self.regions) do
      if region.name == name then return region end
    end

    return nil
  end

  return self
end

return Atlas
