function csh()
    local build = luajava.bindClass("android.os.Build")
    local tools = luajava.bindClass("android.ext.Tools")
    if build.VERSION.SDK_INT > 26 then
        tools.isText = true
    end
end

function cls()
    local bc = gg.getListItems()
    if #bc < 1 then
        gg.alert('保存列表没有数据')
        return
    end
    local mb = gg.getTargetInfo()
    local wj = mb.packageName .. '_base.txt'
    local lj = gg.getFile():gsub('[^/]*$', wj)
    if not gg.saveList(lj, 0) then
        gg.alert('保存列表失败')
        return
    end
    local nr = {}
    local wj = io.open(lj, 'r')
    if not wj then
        gg.alert('无法读取临时文件')
        return
    end
    for h in wj:lines() do
        if h:match("(.-)%.(.+)$") then
            local zs = {}
            for zd in h:gmatch("[^|]+") do
                table.insert(zs, zd)
            end
            
            if #zs >= 11 then
                table.insert(nr, {
                    mk = zs[10]:match('[^/]*$'),
                    pyl = zs[11],
                    lx = tonumber(zs[3], 16),
                    ysz = zs[4]
                })
            end
        end
    end
    wj:close()
    os.remove(lj)
    if #nr == 0 then
        gg.alert('没有有效的数据可以处理')
        return
    end
    return nr
end

function sc(nr, cs)
    local jb = [[
------------------------------------------
-- by.白夜
-- AGG静态基址修改脚本
-- 生成时间: ]] .. os.date("%Y-%m-%d %H:%M:%S") .. [[
------------------------------------------
function szjz(dz, lx, z, dj)
    local zjb = {}
    zjb[1] = {}
    zjb[1].address = dz
    zjb[1].flags = lx
    zjb[1].value = z
    zjb[1].freeze = dj
    gg.setValues(zjb)
    if dj then
        gg.addListItems(zjb)
    end
end

function zh()
    gg.setRanges(gg.REGION_ANONYMOUS | gg.REGION_C_ALLOC)
    gg.clearResults()
]]
    for i, sj in ipairs(nr) do
        local z = cs.sy and sj.ysz or cs.xg or sj.ysz
        local zs = ""
        if cs.tj then
            zs = string.format(" -- 基址%d: %s", i, sj.mk)
        end
        jb = jb .. string.format([[
    local so = gg.getRangesList("%s")[1].start
    szjz(so + 0x%s, %d, "%s", %s)%s
]], 
            sj.mk, 
            sj.pyl,
            sj.lx,
            tostring(z),
            tostring(cs.dj),
            zs
        )
    end
    jb = jb .. [[
    gg.toast("静态基址修改完成")
end

zh()
]]
    return jb
end

function src(nr)
    return function(z)
        if not z then return end
        local cs = {
            xg = z[1] ~= "" and tonumber(z[1]),
            dj = z[2] == "1",
            tj = z[3] == "1",
            sy = z[4] == "1",
            dc = z[5] ~= "" and z[5] or "基址修改.lua"
        }
        local jb = sc(nr, cs)
        local lj = gg.getFile():gsub('/[^/]+$', '/') .. cs.dc
        local wj = io.open(lj, 'w+')
        if not wj then
            gg.alert('无法创建脚本文件')
            return
        end
        wj:write(jb)
        wj:close()
        gg.alert('脚本已导出到:\n' .. lj)
    end
end

function cj(nr)
    local jm = gg.viewPrompt({"修改数值 (留空使用原值)",{"开启冻结", "关闭冻结"},{"添加注释", "不添加注释"},{"使用原值", "使用新值"},"导出文件名"},{"", "2","1","2","基址修改.lua"},{"number","number","number","number","text"},src(nr))
    gg.mainTabs("生成静态基址", jm, false, ck)
end

function sjz()
    local nr = cls()
    if nr then
        cj(nr)
    end
end

function ccd(cd, hd, bt)
    local lb = {}
    for k, v in pairs(cd) do
        table.insert(lb, {
            ["title"] = v[1],
            ["subTitle"] = v[2],
            ["main"] = function(x)
                v[3](x, v[4], v[5])
            end
        })
    end
    local lb = gg.viewList(lb, hd)
    local ck = gg.mainTabs(bt, lb.getView(), false, ck)
    return {["this"] = lb, ["window"] = ck}
end

function xs()
    gg.alert([[
使用说明：
1. 在AGG中保存需要的地址
2. 点击"生成静态基址"
3. 自己设置即可
注意
- - 确保保存列表有数据且是静态的
- - 生成的文件会在执行脚本的目录
]])
end

csh()

cd = ccd({
{"生成静态基址","从保存列表生成静态基址脚本",sjz},{"关于","白夜静态基址生成",xs}},nil,"静态基址生成")
ck = cd.window
ck.setTitle("白夜静态基址生成器")
gg.setVisible(false)
return function()
    gg.toast("基址一键生成加载完成")
end