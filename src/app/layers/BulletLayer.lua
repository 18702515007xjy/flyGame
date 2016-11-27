--
-- Author: Rich
-- Date: 2015-04-11 15:25:19
--
BulletLayer = class("BulletLayer", function ()
	return display.newLayer()
end)

function BulletLayer:getInstance()
	if( _G[BulletLayer] ) then 
		return _G[BulletLayer]
	end

	local _bulletLayer = BulletLayer.new()
	_G[BulletLayer] = _bulletLayer

	_bulletLayer.bulletList = {}		 -- 英雄飞机子弹
	_bulletLayer.monsterbulletList = {}  -- 敌机子弹列表
	_bulletLayer.boombulletList = {}     -- 炸弹列表

	-- 子弹对象池
	_bulletLayer.bulletpool = ObjectPool:new( Bullet,30 )

	function _bulletLayer:pushBullet( target )
		if( target.bullettype == BulletEnum.HERO_BULLET )then
			table.insert( self.bulletList,target )
		elseif( target.bullettype == BulletEnum.MONSTER_BULLET )then
			table.insert( self.monsterbulletList,target )
		elseif( target.bullettype == BulletEnum.HERO_BOOM_BULLET )then
			table.insert( self.boombulletList,target )
		end
		
	end
	function _bulletLayer:popBullet( target,isNoPushPool )
		local index = 1
		local list = nil
		local obj = nil
		if( target.bullettype == BulletEnum.HERO_BULLET )then
			list = self.bulletList
		elseif( target.bullettype == BulletEnum.MONSTER_BULLET )then
			list = self.monsterbulletList
		elseif( target.bullettype == BulletEnum.HERO_BOOM_BULLET )then
			list = self.boombulletList
			isNoPushPool = true
		end

		for k,v in ipairs(list) do
			if( v == target ) then
				obj = table.remove(list,index)
				if( isNoPushPool==true )then break end
				self.bulletpool:pushPool( obj )
				break
			end
			index = index+1
		end
	end

	function _bulletLayer:createBullet( type,point,isTop,count )
		count = count or 0
		if( isTop ) then
			self:createOneBullet( type,point,point.x,display.top )
		else
			self:createOneBullet( type,point,point.x,display.bottom )
		end

		for i=1,count do
			self:createByRotation( type,4*i,point,isTop )
		end

	end

	function _bulletLayer:createByRotation( type,angle,point,isTop )

		local posy = ( isTop and display.top ) or display.bottom
		local h = math.abs( posy - point.y )
		local posx = h*math.tan(math.rad(angle))
		if(isTop) then
			self:createOneBullet( type,point,point.x+posx,posy,angle )
			self:createOneBullet( type,point,point.x-posx,posy,-angle )
		else
			self:createOneBullet( type,point,point.x+posx,posy,-angle )
			self:createOneBullet( type,point,point.x-posx,posy,angle )
		end
		

	end

	function _bulletLayer:createOneBullet( type,point,posx,posy,angle )
		local bullet = self.bulletpool:getTargetForPool()
		if( bullet:getParent() == nil )then
			bullet:addTo(self)
		end
		bullet.bullettype = type
		self:pushBullet( bullet )
		bullet:setPosition(point)
		if( angle ) then
			bullet:setRotation(angle);
		end
		bullet:setTargetPoint( cc.p( posx,posy ) )
	end

	function _bulletLayer:createBoom( point )
		local sp = BoomBullet.new():addTo(self)
		sp:setPosition(point)
		sp.bullettype = BulletEnum.HERO_BOOM_BULLET
		self:pushBullet( sp )
		sp:setTargetPoint()
	end

	function _bulletLayer:isBoomCollision( target,type )

		local list = self.boombulletList

		for key,value in ipairs(list) do
			if( key == nil ) then print("_bulletLayer:isBoomCollision key is nil") break end
			if( value == nil ) then print("_bulletLayer:isBoomCollision value is nil") break end
			if( value:isCollision( target ) ) then
				return true
			end
		end

		return false
	end

	function _bulletLayer:isCollision( target,type )

		local list = nil
		if( type == BulletEnum.HERO_BULLET )then
			list = self.bulletList
		elseif( type == BulletEnum.MONSTER_BULLET )then
			list = self.monsterbulletList
		end

		-- value指子弹
		for key,value in ipairs(list) do
			if( key == nil ) then print("_bulletLayer:isCollision key is nil") break end
			if( value == nil ) then print("_bulletLayer:isCollision value is nil") break end
			if( value:isCollision( target ) ) then
				value:setDead()
				return true
			end
		end

		return false
	end

	function _bulletLayer:clearLayer()
		self.removeAllChildren()
	end

	return _bulletLayer
end

return BulletLayer