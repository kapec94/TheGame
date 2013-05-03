ZIP=zip -r
RM=rm -rf

GAME=game.love

game.love: *.lua
	$(ZIP) $(GAME) *.lua hump HardonCollider atl res

all: game.love

clear:
	$(RM) $(GAME) 
