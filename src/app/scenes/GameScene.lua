

local GameScene = class("GameScene", function()
    return display.newScene("GameScene")
end)

function GameScene:ctor()

	self._time=0

	self:initSrc()
	self:initView()

end

function GameScene:onEnter()
end

function GameScene:onExit()
end

function GameScene:initSrc()
	display.addSpriteFrames( "shoot.plist","shoot.png" )
    display.addSpriteFrames( "BM.plist","BM.png" )
    display.addSpriteFrames( "shoot_background.plist","shoot_background.png" )

    -- 启动节点帧事件，每帧调用一次
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.updateMain))
	-- 启动帧事件
	self:scheduleUpdate()



	--[[--扩展
	-- 0.5 秒后，停止帧事件
	scene:performWithDelay(function()
   		-- 禁用帧事件
    	scene:unscheduleUpdate()
    	print("STOP")

    	-- 再等 0.5 秒，重新启用帧事件
    	scene:performWithDelay(function()
        	-- 再次启用帧事件
        	scene:scheduleUpdate()
        	print("START")
    	end, 0.5)
	end, 0.5)]]


end

function GameScene:initView()
	math.newrandomseed()
	BackgroundLayer.new():addTo(self) --背景滚动层

	BulletLayer:getInstance():addTo(self)
	MonsterLayer:getInstance():addTo(self)
	HeroLayer:getInstance():addTo(self)
	HeroLayer:getInstance():createHero()
	
	-- 炸弹攻击
	local boom = display.newSprite("#bomb.png", display.left+50, 30):addTo(self)
	boom:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.touchBoom))
	boom:setTouchEnabled(true)

	-- 变换子弹
	local buttle = display.newSprite("#ufo1.png", display.left+130, 50):addTo(self)
	buttle:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.touchButtle))
	buttle:setTouchEnabled(true)
end

function GameScene:touchBoom( event )
	if( event.name == "began" ) then
		return true
	end

	if( event.name == "ended" ) then
		HeroLayer:getInstance():boomattack()
	end
end

function GameScene:touchButtle( event )
	if( event.name == "began" ) then
		return true
	end
	if( event.name == "ended" ) then
		HeroLayer:getInstance():addHeroButtle()
	end
end

function GameScene:updateMain( dt )

	self:updateCollision()

	HeroLayer:getInstance():updateLayer( dt )
	MonsterLayer:getInstance():updateLayer( dt )
end



function GameScene:updateCollision()
	local list = MonsterLayer:getInstance().monsterList
	for key,value in ipairs(list) do
		if( key == nil ) then break end
		if( value == nil ) then print("updateMain value is nil") break end
		if( value:isCanConllision() == false ) then break end

		if( BulletLayer:getInstance():isBoomCollision( value,BulletEnum.HERO_BOOM_BULLET ) == false ) then
			local isDead = false
			if( BulletLayer:getInstance():isCollision( value,BulletEnum.HERO_BULLET ) ) then
				-- 敌机扣血  M
				isDead = value:setHurtHp( HeroLayer:getInstance():getPower() )
			end
			if( not(isDead) and HeroLayer:getInstance():isCollision( value ) ) then
				-- 如果敌机没死，敌机碰撞到了英雄飞机
				HeroLayer:getInstance():setHurtHp(1)
			end
		else
			-- 敌机为死亡状态，消除掉
			value:setState("Dead")
		end

		
	end

	-- 英雄飞机与敌机子弹碰撞，英雄飞机减血
	if( BulletLayer:getInstance():isCollision( HeroLayer:getInstance():getHero(),BulletEnum.MONSTER_BULLET ) ) then
		HeroLayer:getInstance():setHurtHp(1)
	end
end

return GameScene
