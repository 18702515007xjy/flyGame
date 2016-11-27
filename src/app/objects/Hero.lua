--
-- Author: Rich
-- Date: 2015-04-02 16:58:34
--

Hero = class("Hero",function ()
	return display.newNode()
end )

function Hero:ctor()
	self.sprite = nil
	self.tint = nil
end

function Hero:onEnter()
	-- body
end

function Hero:onExit()
	-- body
end

function Hero:getRect()
	return 
end

function Hero:initView( data )
	self.data = data
	self.sprite = display.newSprite(self.data.skin):addTo(self)
    self.sprite:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.touchHero))
	self:setState( "Normal" )

	local size = self.sprite:getContentSize();
	self:setContentSize( cc.size(size.width/3, size.height/2) )
end

local beganp=nil

function Hero:touchHero( event )
	if( self.data.state == "Dead" ) then return false end
	if( event.name == "began" ) then
		beganp = cc.p( event.x,event.y )
		return true
	end
	if( event.name =="moved" ) then
		local pox = cc.pSub( cc.p(event.x,event.y), beganp )
		beganp = cc.p( event.x,event.y )
		self:setPosition( cc.pAdd( cc.p( self:getPositionX(),self:getPositionY() ), pox ) )
	end

end

function Hero:setState( state )

	if self.sprite == nil then error("sprite is nil,by remove or not init!",2) end
	self.data.state = state
	print( "hero state",state )
	if state == "Normal" then
		self.sprite:setTouchEnabled(true)
		if( self.data.normalSkin )then
			transition.stopTarget(self.sprite)
			transition.playAnimationForever(self.sprite,display.newAnimation(display.newFrames(self.data.normalSkin,1,2), 0.1))
		end
	elseif state == "Dead" then
		self.sprite:setTouchEnabled(false)
		transition.stopTarget(self.sprite)
		transition.playAnimationOnce(self.sprite,display.newAnimation(
			display.newFrames(self.data.deadSkin,1,4), 0.15), false, self.deadComplete )
	elseif state == "Blink" then
		self.sprite:setTouchEnabled(true)
		transition.stopTarget(self.sprite)
		transition.playAnimationForever(self.sprite,display.newAnimation(display.newFrames(self.data.normalSkin,1,2), 0.1))
		transition.execute(self.sprite, cca.blink(1, 3),{onComplete=function ( target )
			target:getParent():setState("Normal")
		end})
	end
end

function Hero:setTint()
	if  not(self.tint) then
		local x = cca.tintBy(0.2, 0, -1, -1)
		self.tint = transition.execute(self.sprite,cca.seq({ x,x:reverse()}),{onComplete=function (target)
			self.tint = nil
		end})
	end
end

function Hero:deadComplete()
	self:getParent():resetHero()
end


function Hero:isCollision( target )
	local rectA = target:getBoundingBox()
	local rectB = self:getBoundingBox()
	rectA = cc.rect( rectA.x-rectA.width/2,rectA.y + rectA.height/2,rectA.width,rectA.height )
	rectB = cc.rect( rectB.x-rectB.width/2,rectB.y + rectB.height/2,rectB.width,rectB.height )
	return cc.rectIntersectsRect( rectA,rectB )
end

function Hero:resetHero()
	beganp=nil
	self.tint = nil
	self.sprite:removeFromParent()
	HeroLayer:getInstance():setHeroData( ObjectModel:getHeroData() )
	self:setState("Blink")
end