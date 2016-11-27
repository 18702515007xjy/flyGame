--
-- Author: Rich
-- Date: 2015-04-08 11:12:45
--

MonsterLayer = class( "MonsterLayer",function ()
	return display.newLayer()
end )

function MonsterLayer:getInstance()
	if( _G[MonsterLayer] ) then
		return _G[MonsterLayer]
		
	end
	local _monsterLayer = MonsterLayer.new()
	_G[MonsterLayer] = _monsterLayer
	_monsterLayer.monsterList = {}

	-- 对象池
	_monsterLayer.monsterpool = ObjectPool:new( Monster,30 )

	local _time = 0

	function _monsterLayer:pushMonsterList( target )
		table.insert( self.monsterList,target )
	end

	-- 敌机出队列 出完队列加入到对象池中
	function _monsterLayer:popMonsterList( target )
		local index = 1
		for k,v in ipairs(self.monsterList) do
			if( v == target ) then
				self.monsterpool:pushPool(table.remove(self.monsterList,index))
				break
			end
			index = index+1
		end
	end

	function _monsterLayer:clearLayer()
		_monsterLayer.monsterList = {}
		_monsterLayer:removeAllChildren()
	end


	function _monsterLayer:createMonster( startPos,targetPos,data )
		data = data or ObjectModel:getMonsterData()
		local monster = self.monsterpool:getTargetForPool()
		if( monster:getParent() == nil )then
			self:addChild( monster )
		end
		self:pushMonsterList( monster )
		monster:initView( data )
		monster:setPosition( startPos )
		monster:setTargetPoint( targetPos )
		monster.isAttack = math.random()*10 > 8
		return monster
	end

	function _monsterLayer:createTriangleQueueToPoint( count,startPos,targetPos )
		count = count or 3
		
		self:createMonster( startPos,targetPos )

		for i=1,count do
			local value = cc.pMul( {x=30,y=50},i )
			self:createMonster( cc.p( startPos.x-value.x,startPos.y+value.y ),
			cc.p( targetPos.x-value.x,targetPos.y ) )

			self:createMonster( cc.p( startPos.x+value.x,startPos.y+value.y ),
			cc.p( targetPos.x+value.x,targetPos.y ) )

		end
	end

	function _monsterLayer:createOneMonster()
		local startPos = cc.p(display.right*math.random(),display.top)
		local targetPos = cc.p( display.right*math.random(),display.bottom )
		if( HeroLayer:getInstance():isHeroShow() ) then
			targetPos.x = HeroLayer:getInstance():getHeroPosition().x-50+100*math.random()
		end
		self:createMonster( startPos,targetPos )
	end

	function _monsterLayer:createQueue( count )
		local startPos = cc.p(display.right*math.random(),display.top)
		local targetPos = cc.p( display.right*math.random(),display.bottom )
		local value = 100
		count = count or 5
		for i=1,count do
			self:createMonster( cc.p(startPos.x,startPos.y+value),targetPos,ObjectModel:getQuickMonsterData() )
			value = value+100
		end
	end

	function _monsterLayer:createBigMonster()
		local startPos = cc.p(display.right*math.random(),display.top)
		local targetPos = cc.p( display.right*math.random(),display.bottom )
		self:createMonster( cc.p(startPos.x,startPos.y),targetPos,ObjectModel:getMonsterBigData() )
	end

	function _monsterLayer:createBossMonster()
		local startPos = cc.p(display.right*math.random(),display.top)
		local targetPos = cc.p( display.right*math.random(),display.bottom )
		self:createMonster( cc.p(startPos.x,startPos.y),targetPos,ObjectModel:getMonsterBossData() )
	end

	function _monsterLayer:createTriangleQueue( count )
		local startPos = cc.p(display.cx,display.top)
		local targetPos = cc.p( display.right*math.random(),display.bottom )
		self:createTriangleQueueToPoint( count,startPos,targetPos )
	end

	function _monsterLayer:updateLayer( dt )

		_time = _time + dt
		local len = #self.monsterList  -- 数量小于15才创建
		local num = math.random()*10
		if( _time > 1.6 and len < 15 and num > 9 ) then
			if( num > 9.99 ) then
				self:createTriangleQueue()
			elseif ( num > 9.8 ) then
				self:createQueue()
			elseif( num > 9.7 )then
				self:createBigMonster()
			else
				self:createOneMonster()		
			end
		end

		for key,value in ipairs(self.monsterList) do
			if( key == nil ) then print("monsterList key is nil") break end
			if( value == nil ) then print("monsterList value is nil") break end
			value:updateAttack( dt )
		end
		

	end

	return _monsterLayer
end

return MonsterLayer