-- This code was automatically generated by
--        _                  __
--       (_)_  ___________  / /____  __
--      / / / / / ___/ __ \/ //_/ / / /
--     / / /_/ / /  / /_/ / ,< / /_/ /
--  __/ /\__,_/_/   \____/_/|_|\__,_/
-- /___/  by 1lann - github.com/tmpim/juroku
--
-- Usage:
-- local image = require("image")
-- image.draw(term) or image.draw(monitor)
local image = {}

function image.draw(t)
	local x, y = t.getCursorPos()

	t.setPaletteColor(2^0, 0x896A48)
	t.setPaletteColor(2^1, 0xC49784)
	t.setPaletteColor(2^2, 0xB31C11)
	t.setPaletteColor(2^3, 0x635E3E)
	t.setPaletteColor(2^4, 0x45492D)
	t.setPaletteColor(2^5, 0xEFEBEB)
	t.setPaletteColor(2^6, 0x648FD3)
	t.setPaletteColor(2^7, 0x6A3B2B)
	t.setPaletteColor(2^8, 0xCEB0A7)
	t.setPaletteColor(2^9, 0x8E7F7D)
	t.setPaletteColor(2^10, 0xD7C7C2)
	t.setPaletteColor(2^11, 0xE1D7D5)
	t.setPaletteColor(2^12, 0x739CDB)
	t.setPaletteColor(2^13, 0x352820)
	t.setPaletteColor(2^14, 0xC0864F)
	t.setPaletteColor(2^15, 0x89A7D9)
	

	t.setCursorPos(x, y + 0)
	t.blit("\128\128\128\128\128\128\128\132\132\147\132\144\128\144\128\128\128\128\128\128\128\128\128\128\128\128\128\128\138\155\134\159\128\128\128\128", "0000000ccc66060000000000000066660000", "6666666666cccccccccccccccccccccc6666")
	t.setCursorPos(x, y + 1)
	t.blit("\128\128\128\128\128\128\136\147\153\154\128\128\128\128\128\128\128\128\128\128\128\128\128\128\128\128\128\128\128\128\128\129\131\139\144\128", "000000cc66000000000000000000000666c0", "66666666cccccccccccccccccccccccccc66")
	t.setCursorPos(x, y + 2)
	t.blit("\128\128\128\151\152\138\158\131\132\144\128\128\128\128\128\128\128\128\128\128\128\128\128\128\128\128\128\128\128\128\128\128\128\128\128\155", "0006ccc66600000000000000000000000006", "666c666ccccccccccccccccccccccccccccc")
	t.setCursorPos(x, y + 3)
	t.blit("\128\128\159\145\142\151\132\128\128\128\128\128\128\128\128\128\128\128\159\143\131\131\131\131\144\128\128\128\128\128\128\128\128\128\128\128", "0066c6600000000000ccc66c700000000000", "66cc6ccccccccccccc3dddd3cccccccccccc")
	t.setCursorPos(x, y + 4)
	t.blit("\159\128\143\128\159\154\133\128\128\128\128\128\128\128\128\128\159\135\129\128\128\143\128\133\138\153\144\128\128\128\128\128\128\128\128\128", "6060cc6000000000c6300d0dee9000000000", "c6cc66cccccccccc9dddd7d708cccccccccc")
	t.setCursorPos(x, y + 5)
	t.blit("\148\132\159\155\151\129\128\128\143\143\135\131\131\131\143\133\129\128\128\128\159\149\131\135\149\156\136\143\143\144\128\128\128\128\157\128", "66ccc600cc6ccccf6000dd770b9fcf0000c0", "cc666ccc63999646dddd7000eaaaacccccfc")
	t.setCursorPos(x, y + 6)
	t.blit("\138\131\159\133\129\128\128\159\158\135\128\140\135\148\146\143\139\144\133\155\159\130\139\139\133\128\128\139\128\138\159\128\128\159\155\159", "cc66600643033d43d37d73a1e00a0cc00ccc", "66ccccc9399944393dd43018bbbbaffccfff")
	t.setCursorPos(x, y + 7)
	t.blit("\131\128\136\154\136\130\132\133\135\131\132\138\131\139\135\131\146\157\158\128\151\143\133\143\149\135\144\128\138\142\129\131\149\130\129\131", "60fcfff6010344403340d0e88ba0a8ccfccc", "cccfccc31090333304dd3e1aaabbbaffcfff")
	t.setCursorPos(x, y + 8)
	t.blit("\128\128\128\151\157\134\139\145\159\148\128\128\128\158\130\155\159\157\131\128\130\139\134\156\139\130\130\130\128\128\138\128\129\128\128\128", "000ccc610700093333d07e81bbbb00f0c000", "cccffff070999009004dd71aaaaaaaafffff")
	t.setCursorPos(x, y + 9)
	t.blit("\128\155\128\150\129\156\159\147\149\159\131\130\143\129\143\135\138\128\135\138\159\130\130\139\156\139\143\143\143\156\129\128\128\128\128\128", "0c0cc5b100000033003dd7e1e88819800000", "cfcffaa07773334433443d778eee08ffffff")
	t.setCursorPos(x, y + 10)
	t.blit("\139\139\131\137\143\131\137\130\138\149\133\149\133\144\155\133\159\135\133\138\149\142\145\129\147\148\131\131\151\128\128\128\128\128\128\128", "cccffaa1004437444347d77018e180000000", "6666c888e7d344ddd4dd0d0ea18affffffff")
	t.setCursorPos(x, y + 11)
	t.blit("\159\135\143\143\143\139\139\139\133\149\131\151\146\149\149\132\128\129\128\128\131\159\159\143\133\129\129\128\128\128\128\128\128\128\128\128", "9999911180d3744404007d70e88000000000", "30000eeee7704dddddddd70811aaffffffff")
	t.setCursorPos(x, y + 12)
	t.blit("\129\128\128\157\149\138\128\128\128\133\133\148\143\157\157\143\128\128\128\151\131\140\129\143\140\140\138\128\144\128\128\128\128\128\128\128", "00030e000e9937dd000ddbabbbb0a0000000", "3330e1eee0000d44ddd7aabaaaaaffffffff")
	t.setCursorPos(x, y + 13)
	t.blit("\159\130\143\128\130\131\143\143\128\159\144\139\149\138\130\158\128\128\151\149\141\131\129\130\139\156\151\131\139\128\159\131\143\143\131\143", "33300eee0009974400d3baaa89aaf0ffffff", "44433330e2703ddddd79abbbaa199f999999")
	t.setCursorPos(x, y + 14)
	t.blit("\133\128\149\128\144\148\138\128\148\159\149\159\149\157\148\148\128\159\129\145\128\148\128\128\128\139\139\139\131\135\129\128\130\131\130\131", "304044300e070d740d710a0001a999909999", "44333343e07077ddd008abbbbb1a00000000")
	t.setCursorPos(x, y + 15)
	t.blit("\155\128\128\130\128\128\128\128\149\128\149\138\131\133\130\145\159\149\150\145\151\149\128\157\128\138\159\138\148\128\128\128\128\128\128\128", "4003000040000d44d7118a0b088aa0000000", "34444443ee77777d70e8abb5bba890000000")
	t.setCursorPos(x, y + 16)
	t.blit("\128\128\128\128\128\128\128\159\143\135\128\135\128\128\132\128\133\133\128\143\149\133\128\132\132\149\151\139\139\144\128\128\131\132\137\129", "00000004ee070000d0018a055bb1a8000000", "44444449107d777d781eabbbbae883333333")
	t.setCursorPos(x, y + 17)
	t.blit("\128\130\128\144\128\128\151\129\132\136\139\135\131\143\143\138\148\151\151\151\149\128\128\144\128\149\129\149\148\130\128\128\128\128\128\128", "0d030049197d0b1dda1e80050bbba9000000", "444444388185555771e1abbbbaa888333333")
	t.setCursorPos(x, y + 18)
	t.blit("\128\128\128\128\130\128\133\128\135\133\135\128\128\128\128\130\135\129\144\149\149\128\128\128\128\133\138\146\144\149\148\142\144\128\128\128", "0000304088a000080b1e80000baa88134000", "44444418a15555551ae1abbbbaeb1a443333")
	t.setCursorPos(x, y + 19)
	t.blit("\128\128\128\128\128\135\158\134\151\149\138\128\128\128\128\128\148\149\139\149\149\128\128\128\128\149\133\138\149\144\149\128\128\130\144\133", "000003151e50000058ee80000a8ba1a00343", "44444988e8b55555b221abbbb2ba08944434")
	t.setCursorPos(x, y + 20)
	t.blit("\128\128\128\131\133\131\149\128\149\130\133\144\128\128\128\136\144\149\128\149\149\128\128\128\128\151\128\157\133\149\155\128\128\128\128\128", "000448b011bb000b500280000a0bb0800000", "4443bb81eea55555b22eabbbbbbaa8a44444")
	t.setCursorPos(x, y + 21)
	t.blit("\143\128\135\135\159\128\130\135\149\133\148\139\128\128\128\128\149\149\128\149\148\149\128\128\128\128\148\130\130\137\149\149\159\143\128\135", "404b50b8811b000057021a0000abb0834404", "d495b5551e8a5555b22e8bbbbabaa9a4dd4d")
	t.setCursorPos(x, y + 22)
	t.blit("\129\133\128\128\128\128\128\128\130\139\133\148\128\128\128\128\149\151\136\148\149\149\128\128\138\159\133\131\148\128\128\149\128\159\157\128", "44000000b111000057ee1a00aaaab0080d40", "d355555555885555a0008bbbbbbba18dd4dd")
	t.setCursorPos(x, y + 23)
	t.blit("\159\138\145\144\128\128\128\128\128\130\138\148\149\128\159\128\149\128\144\129\149\128\144\128\151\130\139\136\154\144\148\149\128\132\135\128", "dbbb00000b11b050507e10a0bbbab9190440", "3a55555555a855b597008abbaaaba18ddddd")
	
end

function image.getColors()
	local colors = {}
	table.insert(colors, 2^0, 0x896A48)
	table.insert(colors, 2^1, 0xC49784)
	table.insert(colors, 2^2, 0xB31C11)
	table.insert(colors, 2^3, 0x635E3E)
	table.insert(colors, 2^4, 0x45492D)
	table.insert(colors, 2^5, 0xEFEBEB)
	table.insert(colors, 2^6, 0x648FD3)
	table.insert(colors, 2^7, 0x6A3B2B)
	table.insert(colors, 2^8, 0xCEB0A7)
	table.insert(colors, 2^9, 0x8E7F7D)
	table.insert(colors, 2^10, 0xD7C7C2)
	table.insert(colors, 2^11, 0xE1D7D5)
	table.insert(colors, 2^12, 0x739CDB)
	table.insert(colors, 2^13, 0x352820)
	table.insert(colors, 2^14, 0xC0864F)
	table.insert(colors, 2^15, 0x89A7D9)
	
	
	return colors
end

function image.getSize()
	return 36, 24
end

return image
