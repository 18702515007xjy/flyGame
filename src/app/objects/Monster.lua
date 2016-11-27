--
-- Author: Rich
-- Date: 2015-04-01 16:30:21
--
Monster = class( "Monster",function ()
	return display.newNode()
end )

function Monster:ctor()
	self.move = nil   -- 动作对象，方便移除
	self.tint = nil
end

function Monster:initView( data )
	self.data = data
	self.isAttack = false;
	self._time = 0
	self.sprite = display.newSprite(self.data.skin):addTo(self)
	self:setState( "Normal" )
	local size = self.sprite:getContentSize();
	self:setContentSize( size )
end

function Monster:onEnter()
	-- body
end

function Monster:onExit()
	-- body
end

function Monster:setHurtHp( value )
	-- 敌机受伤闪烁动作
	if  not(self.tint) then
		local x = cca.tintBy(0.2, 0, -1, -1)
		self.tint = transition.execute(self.sprite,cca.seq({ x,x:reverse()}),{onComplete=function (target)
			self.tint = nil
		end})
	end
	local hp = self.data.hp - value
	if( hp <= 0 ) then 
		hp = 0
		self:setState( "Dead" )
		return true
	end
	self.data.hp = hp
	return false
end

function Monster:resert()
	self:stopAllActions()
	self:removeAllChildren()
	self:ctor()
end

-- 只有在敌机处于normal状态下才可碰撞
function Monster:isCanConllision()
	return self.data.state == "Normal"
end

function Monster:setState( state )
	if self.sprite == nil then error("sprite is nil,by remove or not init!",2) end
	self.data.state = state
	if state == "Normal" then
		if( self.data.normalSkin )then
			transition.stopTarget(self.sprite)
			transition.playAnimationForever(self.sprite,display.newAnimation(display.newFrames(self.data.normalSkin,1,2), 0.1))
		end
	elseif state == "Dead" then
		transition.stopTarget(self.sprite)
		transition.removeAction(self.move) --移除精灵的动作
		transition.playAnimationOnce(self.sprite,display.newAnimation(
			display.newFrames(self.data.deadSkin,1,4), 0.15), false, self.deadComplete )
	end
end

-- 设置目标点，并移动过去
function Monster:setTargetPoint( point )
	-- selfp:自身的位置  point:需要移动到的位置
	local selfp = cc.p( self:getPositionX(),self:getPositionY() )
	-- 距离
	local distance = cc.pGetDistance( selfp, point )
	local time = distance*self.data.spend
	-- 返回一个动作
	self.move = transition.moveTo(self, { x= point.x, y=point.y,time=time,onComplete= function ( target )
			MonsterLayer:getInstance():popMonsterList( target )
		end })
end

--攻击 
function Monster:updateAttack( dt )
	if( self.data.state ~= "Normal" or self.isAttack ~= true )then return end
	
    -- 敌机处于正常飞行状态，且不处于被攻击状态
	self._time = self._time + dt
	if( self._time > 2 ) then
		self._time = 0
		BulletLayer:getInstance():createBullet( BulletEnum.MONSTER_BULLET,cc.p( self:getPositionX(),
				self:getPositionY()- self:getContentSize().height/2),
				 false)
	end
end

function Monster:deadComplete()
	MonsterLayer:getInstance():popMonsterList( self:getParent() )
end

function Monster:startRotation()
	transition.execute(self.sprite, cca.repeatForever( cca.seq({ cca.scaleBy(1,-1,1),cca.scaleBy(1,-1,1)})))
end