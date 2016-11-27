--
-- Author: Rich
-- Date: 2015-04-02 14:14:01
--
BackgroundLayer = class("BackgroundLayer", function ()
	return display.newLayer()
end)

function BackgroundLayer:initView()
	self.bg1 = display.newSprite("#background.png", display.cx, display.cy):addTo(self)
	self.bg2 = display.newSprite("#background.png", display.cx, display.cy+self.bg1:getContentSize().height-5 ):addTo(self)
				
end

function BackgroundLayer:ctor()
	self.bg1 = nil
	self.bg2 = nil

	self:initView()
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.updateBackground))
	self:scheduleUpdate()
end

function BackgroundLayer:onEnter()

end

function BackgroundLayer:onExit()
	
end

function BackgroundLayer:updateBackground( dt )
	local bg1x = self.bg1:getPositionY() - 100*dt
	local bg2x = self.bg2:getPositionY() - 100*dt
	local bg_height = self.bg1:getContentSize().height

	self.bg1:setPositionY( bg1x )
	self.bg2:setPositionY( bg2x )

	if( bg1x < display.cy-bg_height ) then 
		self.bg1:setPositionY( bg2x+bg_height-5 )
		local bg = self.bg1
		self.bg1 = self.bg2
		self.bg2 = bg
	end

end