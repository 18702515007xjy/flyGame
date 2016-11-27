--
-- Author: Rich
-- Date: 2015-04-11 15:33:55
--
Bullet = class("Bullet", function ()
	return display.newNode()
end)

function Bullet:ctor()
	self.sprite = nil
	self.spend = 0.002
	self.sprite = display.newSprite("#bullet1.png"):addTo(self)
	self:setContentSize( self.sprite:getContentSize().width,self.sprite:getContentSize().height )
end

function Bullet:resert()
	self:stopAllActions()
	self:setRotation(0)
	self:removeAllChildren()
	self:ctor()
end 

function Bullet:onEnter()
	
end

function Bullet:onExit()
	-- body
end

function Bullet:setTargetPoint( point )

	local selfp = cc.p( self:getPositionX(),self:getPositionY() )
	local distance = cc.pGetDistance( selfp, point )
	local time = distance*self.spend
	transition.moveTo(self, { x= point.x, y=point.y,time=time,onComplete= function ( target )
			self:setDead()
		end })
end

function Bullet:setDead()
	BulletLayer:getInstance():popBullet( self )
end

function Bullet:isCollision( target )
	local rectA = target:getBoundingBox()
	local rectB = self:getBoundingBox()
	rectA = cc.rect( rectA.x-rectA.width/2,rectA.y - rectA.height/2,rectA.width,rectA.height )
	rectB = cc.rect( rectB.x-rectB.width/2,rectB.y - rectB.height/2,rectB.width,rectB.height )
	return cc.rectIntersectsRect( rectA,rectB )
end

return Bullet