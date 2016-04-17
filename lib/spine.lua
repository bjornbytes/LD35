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

local spine = {}

spine.utils = require "lib/spine-lua/utils"
spine.SkeletonJson = require "lib/spine-lua/SkeletonJson"
spine.SkeletonData = require "lib/spine-lua/SkeletonData"
spine.BoneData = require "lib/spine-lua/BoneData"
spine.SlotData = require "lib/spine-lua/SlotData"
spine.IkConstraintData = require "lib/spine-lua/IkConstraintData"
spine.Skin = require "lib/spine-lua/Skin"
spine.RegionAttachment = require "lib/spine-lua/RegionAttachment"
spine.MeshAttachment = require "lib/spine-lua/MeshAttachment"
spine.SkinnedMeshAttachment = require "lib/spine-lua/SkinnedMeshAttachment"
spine.Skeleton = require "lib/spine-lua/Skeleton"
spine.Bone = require "lib/spine-lua/Bone"
spine.Slot = require "lib/spine-lua/Slot"
spine.IkConstraint = require "lib/spine-lua/IkConstraint"
spine.AttachmentType = require "lib/spine-lua/AttachmentType"
spine.AttachmentLoader = require "lib/spine-lua/AttachmentLoader"
spine.AtlasAttachmentLoader = require "lib/spine-lua/AtlasAttachmentLoader"
spine.Atlas = require "lib/spine-lua/Atlas"
spine.Animation = require "lib/spine-lua/Animation"
spine.AnimationStateData = require "lib/spine-lua/AnimationStateData"
spine.AnimationState = require "lib/spine-lua/AnimationState"
spine.EventData = require "lib/spine-lua/EventData"
spine.Event = require "lib/spine-lua/Event"
spine.SkeletonBounds = require "lib/spine-lua/SkeletonBounds"

spine.utils.readFile = function (fileName, base)
	local path = fileName
	if base then path = base .. '/' .. path end
	return love.filesystem.read(path)
end

spine.utils.readJSON = function (text)
	return lib.json.decode(text)
end

spine.Skeleton.failed = {} -- Placeholder for an image that failed to load.

spine.Skeleton.new_super = spine.Skeleton.new
function spine.Skeleton.new (skeletonData, group)
	local self = spine.Skeleton.new_super(skeletonData)

	-- createImage can customize where images are found.
	function self:createImage (attachment)
		return love.graphics.newImage(attachment.name .. ".png")
	end

	-- updateWorldTransform positions images.
	local updateWorldTransform_super = self.updateWorldTransform
	function self:updateWorldTransform ()
		updateWorldTransform_super(self)

    if not self.quads then self.quads = {} end
    local quads = self.quads

		if not self.images then self.images = {} end
		local images = self.images

		if not self.attachments then self.attachments = {} end
		local attachments = self.attachments

		for i,slot in ipairs(self.drawOrder) do
			local attachment = slot.attachment
			if not attachment then
				images[slot] = nil
        quads[slot] = nil
			elseif attachment.type == spine.AttachmentType.region then

        if attachment.rendererObject then -- Quad
          local page = attachment.rendererObject.page
          page.image = page.image or self:createAtlasImage(page)
          self.spritebatch = self.spritebatch or love.graphics.newSpriteBatch(page.image, 32, 'stream')
          local quad = quads[slot]
          if quad then
            local u1, v1, u2, v2 = unpack(attachment.uvs)
            local qw, qh = page.image:getDimensions()
            local x, y, w, h = u1 * qw, v1 * qh, (u2 - u1) * qw, (v2 - v1) * qh
            local x2, y2, w2, h2 = quad:getViewport()
            if x ~= x2 or y ~= y2 or w ~= w2 or h ~= h2 then
              quad = nil
            end
          end

          if not quad then
            local x1, y1, x2, y2 = unpack(attachment.uvs)
            local w, h = page.image:getDimensions()
            quad = love.graphics.newQuad(x1 * w, y1 * h, (x2 - x1) * w, (y2 - y1) * h, w, h)
            attachment.widthRatio = attachment.width / attachment.regionWidth
            attachment.heightRatio = attachment.height / attachment.regionHeight
            attachment.originX = attachment.regionWidth / 2
            attachment.originY = attachment.regionHeight / 2
          end
          quads[slot] = quad
        else -- Image

          local image = images[slot]
          if image and attachments[image] ~= attachment then -- Attachment image has changed.
            image = nil
          end
          if not image then -- Create new image.
            image = self:createImage(attachment)
            if image then
              local imageWidth = image:getWidth()
              local imageHeight = image:getHeight()
              attachment.widthRatio = attachment.width / imageWidth
              attachment.heightRatio = attachment.height / imageHeight
              attachment.originX = imageWidth / 2
              attachment.originY = imageHeight / 2
            else
              image = spine.Skeleton.failed
            end
            images[slot] = image
            attachments[image] = attachment
          end
        end
			end
		end
	end

	function self:draw()
		if not self.images then self.images = {} end
		if not self.quads then self.quads = {} end
		local images = self.images
    local quads = self.quads
    local batching = false

		local r, g, b, a = self.r * 255, self.g * 255, self.b * 255, self.a * 255

		for i,slot in ipairs(self.drawOrder) do
			local image = images[slot]
      local quad = quads[slot]
      if quad then
        if not batching then
          batching = true
          self.spritebatch:clear()
        end
				local attachment = slot.attachment
        if attachment then
          local x = slot.bone.worldX + attachment.x * slot.bone.m00 + attachment.y * slot.bone.m01
          local y = slot.bone.worldY + attachment.x * slot.bone.m10 + attachment.y * slot.bone.m11
          local rotation = slot.bone.worldRotation + attachment.rotation
          local xScale = slot.bone.worldScaleX + attachment.scaleX - 1
          local yScale = slot.bone.worldScaleY + attachment.scaleY - 1
          if self.flipX then
            xScale = -xScale
            rotation = -rotation
          end
          if self.flipY then
            yScale = -yScale
            rotation = -rotation
          end
          self.spritebatch:setColor(r * slot.r, g * slot.g, b * slot.b, a * slot.a)
          if slot.data.additiveBlending then
            love.graphics.setBlendMode("additive")
          else
            love.graphics.setBlendMode("alpha")
          end
          self.spritebatch:add(quad,
            self.x + x,
            self.y - y,
            -rotation * 3.1415927 / 180,
            xScale * attachment.widthRatio,
            yScale * attachment.heightRatio,
            attachment.originX,
            attachment.originY)
        end
      elseif image and image ~= spine.Skeleton.failed then
				local attachment = slot.attachment
				local x = slot.bone.worldX + attachment.x * slot.bone.m00 + attachment.y * slot.bone.m01
				local y = slot.bone.worldY + attachment.x * slot.bone.m10 + attachment.y * slot.bone.m11
				local rotation = slot.bone.worldRotation + attachment.rotation
				local xScale = slot.bone.worldScaleX + attachment.scaleX - 1
				local yScale = slot.bone.worldScaleY + attachment.scaleY - 1
				if self.flipX then
					xScale = -xScale
					rotation = -rotation
				end
				if self.flipY then
					yScale = -yScale
					rotation = -rotation
				end
				love.graphics.setColor(r * slot.r, g * slot.g, b * slot.b, a * slot.a)
				if slot.data.additiveBlending then
					love.graphics.setBlendMode("additive")
				else
					love.graphics.setBlendMode("alpha")
				end
				love.graphics.draw(image,
					self.x + x,
					self.y - y,
					-rotation * 3.1415927 / 180,
					xScale * attachment.widthRatio,
					yScale * attachment.heightRatio,
					attachment.originX,
					attachment.originY)
			end
		end

		-- Debug bones.
		if self.debugBones then
			for i,bone in ipairs(self.bones) do
				local xScale
				local yScale
				local rotation = -bone.worldRotation

				if self.flipX then
					xScale = -1
					rotation = -rotation
				else
					xScale = 1
				end

				if self.flipY then
					yScale = -1
					rotation = -rotation
				else
					yScale = 1
				end

				love.graphics.push()
				love.graphics.translate(self.x + bone.worldX, self.y - bone.worldY)
				love.graphics.rotate(rotation * 3.1415927 / 180)
				love.graphics.scale(xScale, yScale)
				love.graphics.setColor(255, 0, 0)
				love.graphics.line(0, 0, bone.data.length, 0)
				love.graphics.setColor(0, 255, 0)
				love.graphics.circle('fill', 0, 0, 3)
				love.graphics.pop()
			end
		end

		-- Debug slots.
		if self.debugSlots then
			love.graphics.setColor(0, 0, 255, 128)
			for i,slot in ipairs(self.drawOrder) do
				local attachment = slot.attachment
				if attachment and attachment.type == spine.AttachmentType.region then
					local x = slot.bone.worldX + attachment.x * slot.bone.m00 + attachment.y * slot.bone.m01
					local y = slot.bone.worldY + attachment.x * slot.bone.m10 + attachment.y * slot.bone.m11
					local rotation = slot.bone.worldRotation + attachment.rotation
					local xScale = slot.bone.worldScaleX + attachment.scaleX - 1
					local yScale = slot.bone.worldScaleY + attachment.scaleY - 1
					if self.flipX then
						xScale = -xScale
						rotation = -rotation
					end
					if self.flipY then
						yScale = -yScale
						rotation = -rotation
					end
					love.graphics.push()
					love.graphics.translate(self.x + x, self.y - y)
					love.graphics.rotate(-rotation * 3.1415927 / 180)
					love.graphics.scale(xScale, yScale)
					love.graphics.rectangle('line', -attachment.width / 2, -attachment.height / 2, attachment.width, attachment.height)
					love.graphics.pop()
				end
			end
		end

    if batching then
      love.graphics.setColor(255, 255, 255)
      love.graphics.draw(self.spritebatch)
    end
	end

	return self
end

return spine
