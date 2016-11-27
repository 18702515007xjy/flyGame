--
-- Author: Rich
-- Date: 2015-05-06 15:59:48
--
BoomBullet = class("BoomBullet", Bullet)

function BoomBullet:ctor()
	self.sprite = nil
	self.sprite = display.newSprite("#BM05.png"):addTo(self)
	self:setContentSize( self.sprite:getContentSize().width,self.sprite:getContentSize().height )
end

function BoomBullet:resert()
	
end

function BoomBullet:onEnter()
	
end

function BoomBullet:onExit()
	-- body
end

function BoomBullet:setTargetPoint( point )
	transition.playAnimationOnce(self.sprite,display.newAnimation(display.newFrames("BM0%d.png",1,9), 0.15), false, self.deadComplete )
end

function BoomBullet:deadComplete()
	BulletLayer:getInstance():popBullet( self:getParent(),true )
	self:getParent():removeAllChildren()
end

function BoomBullet:setDead()
	
end

function BoomBullet:isCollision( target )
	local rectA = cc.p( target:getPositionX(),target:getPositionY() )
	local rectB = cc.p( self:getPositionX(),self:getPositionY() )
	local distance = cc.pGetDistance( rectA, rectB )
	return distance<self:getContentSize().width
end

return BoomBullet