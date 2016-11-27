
require("config")
require("framework.init")
require("app.data.ObjectModel")
require("app.data.ObjectPool")
require("app.enum.BulletEnum")
require("app.objects.Hero")
require("app.objects.Monster")
require("app.objects.Bullet")
require("app.objects.BoomBullet")
require("app.layers.BackgroundLayer")
require("app.layers.MonsterLayer")
require("app.layers.BulletLayer")
require("app.layers.HeroLayer")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    cc.FileUtils:getInstance():addSearchPath("res/")
    self:enterScene("GameScene")
end

return MyApp
