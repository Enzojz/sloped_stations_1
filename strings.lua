function data()
    return {
        en = {
            ["name"] = "Sloped train stations",
            ["desc"] = [[Train staions with slope and height adjustment option. This MOD is based on original pass-through stations.
* Available slopes: 0‰, 10‰, 20‰, 25‰, 30‰, 35‰, 40‰, 50‰, 60‰ 
* Available height options: 0m, 2.5m, 5m, 7.5m and multiper of x0.5, x1, x2, x3, x4, x6. 
Once the slope added to the station, terrain alignment will more probably fail on horizontal ground, choose carefully place and parameters of application. 
---------------
Changelog
08/01/2017:
* Resolved compatibilty with Concrete Flying Junction
01/01/2017:
* Bugfix : Non-accessibilty of middle platforms
25/12/2016: 
* Bugfix : issue that no passenger takes station 
* Negative slope 
* More flexible height options 
--------------- 
* Planned projects 
- Elevated station 
- Underground station 
- Curved station 
- Crossing station 
- Curved station]]
        },
        fr = {
            ["name"] = "Gare en pente",
            ["desc"] = [[Des gares en pente basé sur celles originals dans le jeu.
* Pentes disponibles: 0‰, 10‰, 20‰, 25‰, 30‰, 35‰, 40‰, 50‰, 60‰ 
* Options d'adjustment d'altitude disponible: 0m, 2.5m, 5m, 7.5m avec multiplicateur de x0.5, x1, x2, x3, x4, x6. 
Une fois le pente est ajouté sous la gare, l'alignement de terrain pourrait provoquer une échec, veuillez bien choisir les paramètres pour que ça passe.]],
            ["Slope"] = "Pente",
            ["Sloped train station for cargo."] = "Gare de fret en pente.",
            ["Sloped train station for passengers."] = "Gare voyageurs en pente.",
            ["Altitude Adjustment"] = "Ajustement d'altitude",
            ["Negative slope"] = "Pente négative",
            ["Altitude Adjustment multiple"] = "Multiple de ajustement d'altitude",
        },
        zh_CN = {
            ["name"] = "坡道车站",
            ["desc"] = [[具有倾斜度的火车站，并且带有高度调整的选项。该MOD基于原版的通过式车站
* 可选的坡度: 0‰, 10‰, 20‰, 25‰, 30‰, 35‰, 40‰, 50‰, 60‰
* 可选的高度调整: 0m, 2.5m, 5m, 7.5m，并且可以乘上系数 x0.5, x1, x2, x3, x4, x6. 
当坡度被添加至车站后，可能更容易在平地上引发地面对齐错误，所以请仔细选择放置车站的位置和其参数。]],
            ["Slope"] = "坡度",
            ["Sloped train station for cargo."] = "坡上的货运站",
            ["Sloped train station for passengers."] = "坡上的客运站",
            ["Altitude Adjustment"] = "整体高度调整",
            ["Negative slope"] = "反向坡度",
            ["Altitude Adjustment multiple"] = "高度调整倍数",
        },
    }
end
