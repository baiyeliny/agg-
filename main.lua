function cshHj()
    local Build = luajava.bindClass("android.os.Build")
    local Tools = luajava.bindClass("android.ext.Tools")
    if Build.VERSION.SDK_INT > 26 then
        Tools.isText = true
    end
end

function clJzSj()
    local bcLb = gg.getListItems()
    if #bcLb < 1 then
        gg.alert('保存列表没有数据')
        return
    end
    local mbXx = gg.getTargetInfo()
    local wjMc = mbXx.packageName .. '_base.txt'
    local wjLj = gg.getFile():gsub('[^/]*$', wjMc)
    if not gg.saveList(wjLj, 0) then
        gg.alert('保存列表失败')
        return
    end
    local ncSj = {}
    local wj = io.open(wjLj, 'r')
    if not wj then
        gg.alert('无法读取临时文件')
        return
    end
    for hang in wj:lines() do
        if hang:match("(.-)%.(.+)$") then
            local zjSz = {}
            for zd in hang:gmatch("[^|]+") do
                table.insert(zjSz, zd)
            end
            
            if #zjSz >= 11 then
                table.insert(ncSj, {
                    mk = zjSz[10]:match('[^/]*$'),
                    pyl = zjSz[11],
                    lx = tonumber(zjSz[3], 16),
                    ysz = zjSz[4]
                })
            end
        end
    end
    wj:close()
    os.remove(wjLj)
    if #ncSj == 0 then
        gg.alert('没有有效的数据可以处理')
        return
    end
    return ncSj
end

function scJbNr(ncSj, csXx)
    local jbNr = [[
------------------------------------------
-- by.白夜
-- AGG静态基址修改脚本
-- 生成时间: ]] .. os.date("%Y-%m-%d %H:%M:%S") .. [[
------------------------------------------
function szJzZhi(dz, lx, zhi, dj)
    local zjb = {}
    zjb[1] = {}
    zjb[1].address = dz
    zjb[1].flags = lx
    zjb[1].value = zhi
    zjb[1].freeze = dj
    gg.setValues(zjb)
    if dj then
        gg.addListItems(zjb)
    end
end

function zHans()
    gg.setRanges(gg.REGION_ANONYMOUS | gg.REGION_C_ALLOC)
    gg.clearResults()
]]
    for i, sj in ipairs(ncSj) do
        local zhi = csXx.syYz and sj.ysz or csXx.xgz or sj.ysz
        local zhSm = ""
        if csXx.tjZs then
            zhSm = string.format(" -- 基址%d: %s", i, sj.mk)
        end
        jbNr = jbNr .. string.format([[
    local so = gg.getRangesList("%s")[1].start
    szJzZhi(so + 0x%s, %d, %s, %s)%s
]], 
            sj.mk, 
            sj.pyl,
            sj.mk,
            sj.pyl,
            sj.lx,
            zhi,
            tostring(csXx.djZhi),
            zhSm
        )
    end
    jbNr = jbNr .. [[
    gg.toast("静态基址修改完成")
end

zHans()
]]
    return jbNr
end

function srJmHd(ncSj)
    return function(zhi)
        if not zhi then return end
        local csXx = {
            xgz = zhi[1] ~= "" and tonumber(zhi[1]),
            djZhi = zhi[2] == "1",
            tjZs = zhi[3] == "1",
            syYz = zhi[4] == "1",
            dcWj = zhi[5] ~= "" and zhi[5] or "基址修改.lua"
        }
        local jbNr = scJbNr(ncSj, csXx)
        local jbLj = gg.getFile():gsub('/[^/]+$', '/') .. csXx.dcWj
        local wj = io.open(jbLj, 'w+')
        if not wj then
            gg.alert('无法创建脚本文件')
            return
        end
        wj:write(jbNr)
        wj:close()
        gg.alert('脚本已导出到:\n' .. jbLj)
    end
end

function cjSrJm(ncSj)
local jm = gg.viewPrompt({"修改数值 (留空使用原值)",{"开启冻结", "关闭冻结"},{"添加注释", "不添加注释"},{"使用原值", "使用新值"},"导出文件名"},{"", "2","1","2","基址修改.lua"},{"number","number","number","number","text"},srJmHd(ncSj))
gg.mainTabs("生成静态基址", jm, false, cKuang)
end

function scJtJz()
    local ncSj = clJzSj()
    if ncSj then
        cjSrJm(ncSj)
    end
end

function cjCdLb(cdSj, hdHs, btWz)
    local lb = {}
    for k, v in pairs(cdSj) do
        table.insert(lb, {
            ["title"] = v[1],
            ["subTitle"] = v[2],
            ["main"] = function(xm)
                v[3](xm, v[4], v[5])
            end
        })
    end
    local lb = gg.viewList(lb, hdHs)
    local ck = gg.mainTabs(btWz, lb.getView(), false, cKuang)
    return {["this"] = lb, ["window"] = ck}
end

function xsGyXx()
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

cshHj()

cdBiao = cjCdLb({
{"生成静态基址","从保存列表生成静态基址脚本",scJtJz},{"关于","静态基址生成器",xsGyXx}},nil,"静态基址生成")
cKuang = cdBiao.window
cKuang.setTitle("静态基址生成器")
gg.setVisible(false)
return function()
    gg.toast("基址一键生成加载完成")
end