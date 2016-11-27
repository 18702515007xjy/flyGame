--
-- Author: Rich
-- Date: 2015-04-11 15:59:41
--
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

HeroLayer = class("HeroLayer", function ()
	return display.newLayer()
end)

function HeroLayer:getInstance()
	if( _G[HeroLayer] ) then
		return _G[HeroLayer]
	end
	local _heroLayer = HeroLayer.new()
	_G[HeroLayer] = _heroLayer

	local _hero = nil
	local _heroData = nil
	local _time = 0
	local count = 0
	local buttleNum = 0
	function _heroLayer:createHero()

		_heroData = ObjectModel:getHeroData()
		_hero = Hero.new():addTo(self)
		_hero:initView( _heroData )
		_hero:setPosition(display.cx, display.cy)
	end


    -- 变换子弹与炸弹--
    -----------------------------------
	function _heroLayer:addHeroButtle()
		print(buttleNum)
		buttleNum=buttleNum+1
		if( buttleNum >= 6 )then
			buttleNum = 0
		end
	end

	function _heroLayer:boomattack()
		if( _heroLayer.handle==nil )then
			count = 0
			_heroLayer.handle = scheduler.scheduleGlobal(self.touchHero, 0.2)
		end
	end

	function _heroLayer:touchHero( dt )
		if( count > 20 ) then
			scheduler.unscheduleGlobal( _heroLayer.handle )
			_heroLayer.handle = nil
		else
			BulletLayer:getInstance():createBoom( cc.p( display.width*math.random(),display.cy-100+400*math.random() ) )

		end
		count=count+1
	end
    -----------------------------------

	function _heroLayer:getHero()
		return _hero
	end

	function _heroLayer:getHeroPosition()
		return cc.p(_hero:getPositionX(),_hero:getPositionY())
	end

	function _heroLayer:getHeroContentSize()
		return _hero:getContentSize()
	end

	function _heroLayer:isCollision( target )
		if( self:isHeroCanByHit() == false ) then return false end
		return _hero:isCollision(target)
	end

	function _heroLayer:setHeroState( state )
		_hero:setState(state)
	end

	function _heroLayer:resetHero()
		_hero:addTo(self)
		_hero:resetHero()
	end

	function _heroLayer:isHeroShow()
		return not(_heroData.state == "Dead") 
	end

	function _heroLayer:isHeroCanByHit()
		if( _heroData.state == "Blink" ) then return false end
		if( _heroData.state == "Dead" ) then return false end
		return true 
	end

	function _heroLayer:setPower( value )
		_heroData.power = value
	end

	function _heroLayer:getPower()
		return _heroData.power
	end

	function _heroLayer:getHeroData()
		return _heroData
	end
	function _heroLayer:setHeroData( data )
		_heroData = data
		_hero:initView( _heroData )
	end

	function _heroLayer:setHurtHp( value )
		if( self:isHeroCanByHit() == false ) then return false end
		_hero:setTint()
		local hp = _heroData.hp - value

		if( hp<=0 )then
			hp = 0
			_heroData.hp = 0
			_hero:setState("Dead")
			return true
		end
		_heroData.hp = hp
		return false
	end

	function _heroLayer:updateLayer( dt )
		_time = _time + dt
		if( _time > 0.2 and self:isHeroShow() ) then
			_time = 0
			
			BulletLayer:getInstance():createBullet( BulletEnum.HERO_BULLET,cc.p( self:getHeroPosition().x,
				self:getHeroPosition().y+ self:getHeroContentSize().height/2),
				 true,buttleNum)
		end
	end

	return _heroLayer
end

return HeroLayer