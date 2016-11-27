--
-- Author: Rich
-- Date: 2015-04-22 22:13:51
--
ObjectPool = {}

function ObjectPool:new(  _type, max )
	max = max or 20

	local _objectPool = {}
	_objectPool._pool = {}

	function _objectPool:pushPool( target )

		if( max > #self._pool ) then-- _pool容器还能装得下	
			-- 把新的对象插入到对象池中	
			table.insert(self._pool,target)
			-- 并把对象属性初始化
			target:resert()
			-- 并且设置不可见
			target:setVisible(false)
		else
			target:removeFromParent()
		end
		
	end
	function _objectPool:getTargetForPool()
		-- 对象池中没有元素时候 直接new一个返回
		local len = #self._pool
		if( len <= 0 )then
			return _type.new()
		end

		-- 要不然直接从对象池中取一个(最后一个)返回
		local target = table.remove(self._pool)
		-- 不要忘了设置为可见
		target:setVisible(true)
		return target
	end

	return _objectPool
end
